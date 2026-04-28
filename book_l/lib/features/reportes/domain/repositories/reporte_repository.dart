import '../entities/reporte.dart';
import '../entities/reporte_agrupado.dart';

abstract class ReporteRepository {
  Future<List<Reporte>> getReportes();
  Future<List<ReporteAgrupado>> getReportesAgrupados();
  Future<List<Reporte>> getReportesPorEntidad(String tipo, int id);
  Future<void> addReporte({
    required int idUsuarioFk,
    required String entidadTipo,
    required int entidadId,
    required String motivo,
  });
}
