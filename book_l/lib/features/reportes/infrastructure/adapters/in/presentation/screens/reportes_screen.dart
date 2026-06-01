import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/shared/widgets/search_filter_bar.dart';
import '../controller/reportes_controller.dart';
import 'package:book_l/features/reportes/application/usecases/get_reportes_agrupados_usecase.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/out/repositories/reportes_repository_impl.dart';
import 'package:book_l/features/reportes/domain/models/reporte_agrupado.dart';

ReportesController _buildController() {
  final repo = ReportesRepositoryImpl();
  return ReportesController(
    getReportesAgrupadosUseCase: GetReportesAgrupadosUseCase(repo),
  );
}

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ReportesController _controller;

  final List<String> _filtros = [
    'Todos',
    'Recientes',
    'Más reportados',
    'Cursos',
    'Lecciones',
    'Capítulos'
  ];
  int _filtroSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _controller.loadReportes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          // ── COLUMNA PRINCIPAL ──────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER: SVG completo como fondo con overlay de contenido
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      // Fondo de imagen roja replicando estructura visual de Lecciones
                      Image.asset(
                        'assets/images/red_bg.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Botón atrás (esquina superior izquierda)
                      Positioned(
                        top: topPadding + 8,
                        left: 20,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      // Título "Reportes"
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 80,
                        child: const Center(
                          child: Text(
                            'Reportes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontFamily: 'Baloo',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── ZONA GRIS con búsqueda, filtros y listado ──────────────
              Expanded(
                child: Column(
                  children: [
                    SearchFilterBar(
                      activeColor: const Color(0xFFFF606F),
                      searchController: _searchController,
                      query: _searchController.text,
                      onQueryChanged: (v) => _controller.onSearchChanged(v),
                      onClear: () {
                        _searchController.clear();
                        _controller.onSearchChanged('');
                      },
                      filtros: _filtros,
                      filtroSeleccionado: _filtroSeleccionado,
                      onFiltroChanged: (index) {
                        setState(() => _filtroSeleccionado = index);
                        _controller.onFilterChanged(_filtros[index]);
                      },
                    ),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) {
                          if (_controller.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFFF606F)),
                            );
                          }

                          if (_controller.errorMessage.isNotEmpty) {
                            return Center(
                                child: Text(
                                    'Error: ${_controller.errorMessage}',
                                    style: const TextStyle(color: Colors.red)));
                          }

                          final reportes = _controller.reportes;

                          if (reportes.isEmpty) {
                            return const Center(
                                child: Text('No hay reportes disponibles',
                                    style:
                                        TextStyle(color: Color(0xFF888888))));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 100,
                            ),
                            itemCount: reportes.length,
                            itemBuilder: (context, index) {
                              return _buildReporteCard(
                                  context, reportes[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── BOTTOM NAV BAR ─────────────────────────────────────────────
          const Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SharedBottomNavBar(selectedIndex: 3, role: 'admin'),
          ),
        ],
      ),
    );
  }

  Widget _buildReporteCard(BuildContext context, ReporteAgrupado item) {
    Color boxColor = const Color(0xFFD9D9D9);
    final tipoL = item.tipoEntidad.toLowerCase().replaceAll('ó', 'o');
    if (tipoL == 'curso')
      boxColor = const Color(0xFFFF606F);
    else if (tipoL == 'leccion')
      boxColor = const Color(0xFF5AB639);
    else if (tipoL == 'capitulo') boxColor = const Color(0xFFFFB800);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/reporte_detail',
              arguments: {
                'id_leccion': item.idEntidad,
                'nombre': item.nombreEntidad,
                'tipo': item.tipoEntidad,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.report_problem_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),

                // Info central
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estado badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.tipoEntidad,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Título
                      Text(
                        item.nombreEntidad,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111111),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.cantidadReportes == 1
                            ? '1 reporte'
                            : '${item.cantidadReportes} reportes',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 3),
                      const Row(
                        children: [
                          Icon(Icons.star, size: 13, color: Color(0xFFF6B55C)),
                          SizedBox(width: 3),
                          Text('4.9',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111111))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
