import 'package:flutter/material.dart';
import '../../../../shared/widgets/search_filter_bar.dart';
import '../../../../shared/widgets/content_cards.dart';
import '../../../guardado/presentation/controller/guardado_controller.dart';

class MisFavoritosTabWidget extends StatefulWidget {
  const MisFavoritosTabWidget({super.key});

  @override
  State<MisFavoritosTabWidget> createState() => _MisFavoritosTabWidgetState();
}

class _MisFavoritosTabWidgetState extends State<MisFavoritosTabWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final List<String> _filtros = ['Todas', 'Recientes', 'Calificación', 'Populares', 'Duración'];
  int _filtroSeleccionado = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GuardadoController(),
      builder: (context, _) {
        final ctrl = GuardadoController();
        var misLecciones = ctrl.getSavedLecciones();
        var misCursos = ctrl.getSavedCursos();

        // Aplicamos la búsqueda local
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          misLecciones = misLecciones.where((l) => l.nombre.toLowerCase().contains(q)).toList();
          misCursos = misCursos.where((c) => c.nombre.toLowerCase().contains(q)).toList();
        }

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
                    onFiltroChanged: (idx) => setState(() => _filtroSeleccionado = idx),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
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
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                        _buildList(misLecciones, true),
                        _buildList(misCursos, false),
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
          'No tienes favoritos guardados aún.',
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
