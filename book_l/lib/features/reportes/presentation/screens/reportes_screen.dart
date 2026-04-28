import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../widgets/reporte_card.dart';
import '../controller/reportes_controller.dart';
import '../../domain/usecases/get_reportes_agrupados_usecase.dart';
import '../../data/repositories/reportes_repository_impl.dart';

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

  final List<String> _filters = ['Todos', 'Cursos', 'Lecciones', 'Capítulos'];

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
      backgroundColor: const Color(0xFFFFF9E1), // Crema claro
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/red_bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),
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
                      // Icono campana (esquina superior derecha)
                      Positioned(
                        top: topPadding + 8,
                        right: 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      // Título "Reportes"
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 80,
                        child: Center(
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

              // ── CONTENIDO ──────────────
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSearchBar(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFilters(),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) => SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildReportList(),
                              const SizedBox(
                                  height:
                                      120), // Espacio para el navbar flotante
                            ],
                          ),
                        ),
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

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _controller.onSearchChanged(val),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                hintText: 'Buscar por nombre...',
                hintStyle: const TextStyle(color: Colors.black54),
                suffixIcon: IconButton(
                  icon:
                      const Icon(Icons.close, size: 20, color: Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    _controller.onSearchChanged('');
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF5AB639),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _controller.selectedFilter == filter;
                return GestureDetector(
                  onTap: () => _controller.onFilterChanged(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5AB639)
                          : const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildReportList() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child:
            Center(child: CircularProgressIndicator(color: Color(0xFF5AB639))),
      );
    }

    if (_controller.errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('Error: ${_controller.errorMessage}',
            style: const TextStyle(color: Colors.red)),
      );
    }

    final reportesAgrupados = _controller.reportes;

    if (reportesAgrupados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No se encontraron reportes con estos criterios.',
            style: TextStyle(color: Colors.black54)),
      );
    }

    return Column(
      children: reportesAgrupados.map((item) {
        Color boxColor = const Color(0xFFD9D9D9);
        final tipoL = item.tipoEntidad.toLowerCase().replaceAll('ó', 'o');
        if (tipoL == 'curso') {
          boxColor = const Color(0xFFFF606F);
        } else if (tipoL == 'leccion')
          boxColor = const Color(0xFF5AB639);
        else if (tipoL == 'capitulo') boxColor = const Color(0xFFFFB800);

        return ReporteCard(
          title: item.nombreEntidad,
          subtitle: item.tipoEntidad,
          rating: 4.9, // Podría parametrizarse
          reportCount: item.cantidadReportes,
          tags: [item.tipoEntidad],
          boxColor: boxColor,
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
        );
      }).toList(),
    );
  }
}
