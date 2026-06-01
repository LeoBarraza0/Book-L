import 'package:flutter/material.dart';
import '../controller/perfil_controller.dart';
import 'package:book_l/shared/widgets/search_filter_bar.dart';
import 'package:book_l/shared/widgets/content_cards.dart';

/// Tab de "Mis Contenidos" en el Perfil.
/// Fuente única de datos: [PerfilController]. Filtrado por userId activo.
class MisContenidosTabWidget extends StatefulWidget {
  final int idUsuario;
  const MisContenidosTabWidget({super.key, required this.idUsuario});

  @override
  State<MisContenidosTabWidget> createState() => _MisContenidosTabWidgetState();
}

class _MisContenidosTabWidgetState extends State<MisContenidosTabWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final List<String> _filtros = [
    'Todas',
    'Recientes',
    'Calificación',
    'Populares',
    'Duración',
  ];
  int _filtroSeleccionado = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PerfilController(),
      builder: (context, _) {
        final userId = widget.idUsuario;

        // Fuente única: PerfilController. Filtramos por usuario activo.
        final misLecciones = PerfilController().getLeccionesDeUsuario(userId);
        final misCursos = PerfilController().getCursosDeUsuario(userId);

        final filteredLecciones = _query.isEmpty
            ? misLecciones
            : misLecciones
                .where((l) =>
                    l.nombre.toLowerCase().contains(_query.toLowerCase()))
                .toList();
        final filteredCursos = _query.isEmpty
            ? misCursos
            : misCursos
                .where((c) =>
                    c.nombre.toLowerCase().contains(_query.toLowerCase()))
                .toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(
                  height:
                      16), // Espacio extra bajo la pestaña de Favoritos/Grid
              SearchFilterBar(
                searchController: _searchController,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
                onClear: () {
                  setState(() {
                    _searchController.clear();
                    _query = '';
                  });
                },
                filtros: _filtros,
                filtroSeleccionado: _filtroSeleccionado,
                onFiltroChanged: (idx) =>
                    setState(() => _filtroSeleccionado = idx),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48, // Ajustable
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFD9D9D9), // Gris más oscuro, usado en la app
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.zero,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: const Color(0xFF4DC130),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Lecciones'),
                      Tab(text: 'Cursos'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildList(filteredLecciones, true),
                    _buildList(filteredCursos, false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<dynamic> items, bool isLeccion) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Ningún contenido encontrado.',
          style: TextStyle(color: Color(0xFF888888), fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (isLeccion) {
          return SharedLeccionCard(leccion: item);
        } else {
          return SharedCursoCard(curso: item);
        }
      },
    );
  }
}
