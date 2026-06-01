import 'package:flutter/material.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/reportes/domain/models/reporte.dart';
import 'package:book_l/features/reportes/application/usecases/get_reportes_por_entidad_usecase.dart';

class ReporteCompletoInfo {
  final Reporte reporte;
  final String nombreUsuario;
  final String? avatarUrl;

  ReporteCompletoInfo({
    required this.reporte,
    required this.nombreUsuario,
    this.avatarUrl,
  });
}

class ReporteDetailController extends ChangeNotifier {
  final GetReportesPorEntidadUseCase getReportesPorEntidadUseCase;

  List<ReporteCompletoInfo> _allComentarios = [];
  List<ReporteCompletoInfo> _displayedComentarios = [];

  bool isLoading = true;
  String errorMessage = '';

  String _selectedSort = 'Más Recientes';

  ReporteDetailController({required this.getReportesPorEntidadUseCase});

  List<ReporteCompletoInfo> get comentarios => _displayedComentarios;
  String get selectedSort => _selectedSort;

  Future<void> loadDetalles(String tipo, int id) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final reportesRaw = await getReportesPorEntidadUseCase(
        GetReportesPorEntidadParams(tipo: tipo, id: id),
      );

      // Cruzar con los usuarios reales para tener los avatares y nombres reales
      // Debido a que BooklService actúa como backend mock, le pediremos la info de usuarios aquí (como si fuese un JOIN o Included en backend)
      final usuarios = BooklService().usuarios;

      _allComentarios = reportesRaw.map((r) {
        final user =
            usuarios.where((u) => u.idUsuario == r.idUsuarioFk).firstOrNull;
        return ReporteCompletoInfo(
          reporte: r,
          nombreUsuario: user?.nombreCompleto ?? 'Usuario (${r.idUsuarioFk})',
          avatarUrl: user?.avatarUrl,
        );
      }).toList();

      _applySort();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onChangeSort(String sortOpt) {
    if (_selectedSort == sortOpt) return;
    _selectedSort = sortOpt;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    _displayedComentarios = List.from(_allComentarios);
    if (_selectedSort == 'Más Recientes') {
      _displayedComentarios
          .sort((a, b) => b.reporte.createdAt.compareTo(a.reporte.createdAt));
    } else if (_selectedSort == 'Más Antiguos') {
      _displayedComentarios
          .sort((a, b) => a.reporte.createdAt.compareTo(b.reporte.createdAt));
    }
  }
}
