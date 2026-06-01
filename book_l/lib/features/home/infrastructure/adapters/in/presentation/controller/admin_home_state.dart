import 'package:book_l/features/reportes/domain/models/reporte.dart';
import 'package:book_l/features/reportes/application/usecases/get_estadisticas_reportes_usecase.dart';
import 'package:book_l/features/home/domain/models/novedad.dart';

abstract class AdminHomeState {}

class AdminHomeInitial extends AdminHomeState {}

class AdminHomeLoading extends AdminHomeState {}

class AdminHomeLoaded extends AdminHomeState {
  final List<ReportePuntoChart> chartData;
  final PeriodoFiltro periodoActual;
  final List<Novedad> novedades;

  AdminHomeLoaded({
    required this.chartData,
    required this.periodoActual,
    required this.novedades,
  });
}

class AdminHomeError extends AdminHomeState {
  final String message;
  AdminHomeError(this.message);
}
