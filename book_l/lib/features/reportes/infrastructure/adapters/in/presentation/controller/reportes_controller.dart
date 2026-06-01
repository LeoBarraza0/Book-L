import 'package:flutter/material.dart';
import 'package:book_l/core/usecase/usecase.dart';
import 'package:book_l/features/reportes/domain/models/reporte_agrupado.dart';
import 'package:book_l/features/reportes/application/usecases/get_reportes_agrupados_usecase.dart';

class ReportesController extends ChangeNotifier {
  final GetReportesAgrupadosUseCase getReportesAgrupadosUseCase;

  List<ReporteAgrupado> _allReportes = [];
  List<ReporteAgrupado> _filteredReportes = [];

  bool isLoading = true;
  String errorMessage = '';

  String _searchQuery = '';
  String _selectedFilter = 'Todos';

  ReportesController({required this.getReportesAgrupadosUseCase});

  List<ReporteAgrupado> get reportes => _filteredReportes;
  String get selectedFilter => _selectedFilter;

  Future<void> loadReportes() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      _allReportes = await getReportesAgrupadosUseCase(const NoParams());
      _applyFilters();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = _allReportes.toList();

    // 1. Filtrar por Búsqueda (Texto)
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((reporte) =>
              reporte.nombreEntidad.toLowerCase().contains(_searchQuery))
          .toList();
    }

    // 2. Filtrar o Ordenar por el filtro seleccionado
    if (_selectedFilter == 'Recientes') {
      result.sort((a, b) => (b.ultimaFechaReporte ?? DateTime(0))
          .compareTo(a.ultimaFechaReporte ?? DateTime(0)));
    } else if (_selectedFilter == 'Más reportados') {
      result.sort((a, b) => b.cantidadReportes.compareTo(a.cantidadReportes));
    } else if (_selectedFilter != 'Todos') {
      // Filtrar por tipo (Cursos, Lecciones, Capítulos)
      result = result.where((reporte) {
        final tipoLower =
            reporte.tipoEntidad.toLowerCase().replaceAll('ó', 'o');
        if (_selectedFilter == 'Cursos' && tipoLower != 'curso') return false;
        if (_selectedFilter == 'Lecciones' && tipoLower != 'leccion')
          return false;
        if (_selectedFilter == 'Capítulos' && tipoLower != 'capitulo')
          return false;
        return true;
      }).toList();
    }

    _filteredReportes = result;
  }
}
