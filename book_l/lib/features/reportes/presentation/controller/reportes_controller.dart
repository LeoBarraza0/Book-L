import 'package:flutter/material.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/reporte_agrupado.dart';
import '../../domain/usecases/get_reportes_agrupados_usecase.dart';

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
    _filteredReportes = _allReportes.where((reporte) {
      // 1. Filtrar por Tipo
      bool matchesType = true;
      if (_selectedFilter != 'Todos') {
        final tipoLower = reporte.tipoEntidad.toLowerCase().replaceAll('ó', 'o');
        final filterLower = _selectedFilter.toLowerCase()
            .replaceAll('s', '') // 'Cursos' -> 'Curso', 'Lecciones' -> 'Leccion'
            .replaceAll('e', '') // Manejo simple, ej. Leccion(es), Capitul(os)
            .replaceAll('ó', 'o');
        
        // Manejo específico rápido
        if (_selectedFilter == 'Cursos' && tipoLower != 'curso') matchesType = false;
        if (_selectedFilter == 'Lecciones' && tipoLower != 'leccion') matchesType = false;
        if (_selectedFilter == 'Capítulos' && tipoLower != 'capitulo') matchesType = false;
      }

      // 2. Filtrar por Búsqueda (Texto)
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        matchesSearch = reporte.nombreEntidad.toLowerCase().contains(_searchQuery);
      }

      return matchesType && matchesSearch;
    }).toList();
  }
}
