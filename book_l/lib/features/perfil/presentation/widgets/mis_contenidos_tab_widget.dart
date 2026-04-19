import 'package:flutter/material.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../shared/widgets/search_filter_bar.dart';

class MisContenidosTabWidget extends StatefulWidget {
  const MisContenidosTabWidget({super.key});

  @override
  State<MisContenidosTabWidget> createState() => _MisContenidosTabWidgetState();
}

class _MisContenidosTabWidgetState extends State<MisContenidosTabWidget> {
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
      listenable: BooklService(),
      builder: (context, _) {
        final userId = AppSession().usuarioId;
        var misLecciones = BooklService().lecciones.where((l) => l.idUsuarioFk == userId).toList();
        var misCursos = BooklService().cursos.where((c) => c.idUsuarioFk == userId).toList();

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
              const SizedBox(height: 16), // Espacio extra bajo la pestaña de Favoritos/Grid
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
                  height: 48, // Ajustable
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9), // Gris más oscuro, usado en la app
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.zero,
                    indicatorPadding: const EdgeInsets.all(4),
                    indicator: BoxDecoration(
                      color: const Color(0xFF4DC130), // Verde corporativo
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
          return _buildLeccionCard(item, context);
        } else {
          return _buildCursoCard(item, context);
        }
      },
    );
  }

  Widget _buildLeccionCard(dynamic leccion, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/editar_leccion', arguments: leccion.idLeccion);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DC130),
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=2070'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8BCA39),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('JAVA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8BCA39),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('P.O.O.', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          leccion.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
                            SizedBox(width: 2),
                            Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                            SizedBox(width: 8),
                            Icon(Icons.access_time_filled, color: Color(0xFF555555), size: 14),
                            SizedBox(width: 2),
                            Text('1 Hora', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF555555))),
                            SizedBox(width: 8),
                            Icon(Icons.people_alt, color: Color(0xFF555555), size: 14),
                            SizedBox(width: 2),
                            Text('1200', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF555555))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.2, // 20%
                      backgroundColor: Colors.white,
                      color: const Color(0xFF4DC130),
                      strokeWidth: 4,
                    ),
                    const Center(
                      child: Text(
                        '20%',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCursoCard(dynamic curso, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/editar_curso', arguments: curso.idCurso);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF8BCA39).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF4DC130), size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text('Toca para editar', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
