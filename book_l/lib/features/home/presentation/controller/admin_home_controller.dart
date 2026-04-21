import 'package:flutter/material.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../reportes/domain/usecases/get_estadisticas_reportes_usecase.dart';
import '../../domain/usecases/get_novedades_usecase.dart';
import 'admin_home_state.dart';

class AdminHomeController extends ChangeNotifier {
  final GetEstadisticasReportesUseCase getEstadisticasReportes;
  final GetNovedadesUseCase getNovedades;

  AdminHomeState _state = AdminHomeInitial();
  AdminHomeState get state => _state;

  PeriodoFiltro _periodoActual = PeriodoFiltro.diario;
  PeriodoFiltro get periodoActual => _periodoActual;

  AdminHomeController({
    required this.getEstadisticasReportes,
    required this.getNovedades,
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
      // Cargar gráfica y novedades en paralelo para no bloquear la UI
      final results = await Future.wait([
        getEstadisticasReportes(
          GetEstadisticasReportesParams(periodo: _periodoActual),
        ),
        getNovedades(const NoParams()),
      ]);

      _setState(AdminHomeLoaded(
        chartData: results[0] as dynamic,
        periodoActual: _periodoActual,
        novedades: results[1] as dynamic,
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
