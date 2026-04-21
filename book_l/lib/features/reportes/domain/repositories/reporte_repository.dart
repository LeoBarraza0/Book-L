import '../entities/reporte.dart';
import '../entities/reporte_agrupado.dart';

abstract class ReporteRepository {
  Future<List<Reporte>> getReportes();
  Future<List<ReporteAgrupado>> getReportesAgrupados();
  Future<List<Reporte>> getReportesPorEntidad(String tipo, int id);
}
