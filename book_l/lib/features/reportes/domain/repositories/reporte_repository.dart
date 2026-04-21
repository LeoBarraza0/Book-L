import '../entities/reporte.dart';

abstract class ReporteRepository {
  Future<List<Reporte>> getReportes();
}
