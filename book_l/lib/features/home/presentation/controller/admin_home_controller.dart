import 'package:flutter/material.dart';

import '../../../reportes/domain/usecases/get_estadisticas_reportes_usecase.dart';
import 'admin_home_state.dart';

class AdminHomeController extends ChangeNotifier {
  final GetEstadisticasReportesUseCase getEstadisticasReportes;

  AdminHomeState _state = AdminHomeInitial();
  AdminHomeState get state => _state;

  PeriodoFiltro _periodoActual = PeriodoFiltro.diario;
  PeriodoFiltro get periodoActual => _periodoActual;

  AdminHomeController({
    required this.getEstadisticasReportes,
  });

  void _setState(AdminHomeState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> cargarDashboard({PeriodoFiltro? periodo}) async {
    if (periodo != null) {
      _periodoActual = periodo;
    }
    
    _setState(AdminHomeLoading());

    try {
      final chartData = await getEstadisticasReportes(
        GetEstadisticasReportesParams(periodo: _periodoActual),
      );

      _setState(AdminHomeLoaded(
        chartData: chartData,
        periodoActual: _periodoActual,
      ));
    } catch (e) {
      _setState(AdminHomeError(e.toString()));
    }
  }

  Future<void> cambiarPeriodo(PeriodoFiltro nuevoPeriodo) async {
    if (_periodoActual == nuevoPeriodo && _state is AdminHomeLoaded) return;
    await cargarDashboard(periodo: nuevoPeriodo);
  }
}
