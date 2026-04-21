import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repositories/reporte_repository.dart';
import '../dto/reporte_dto.dart';

class ReportesRepositoryImpl implements ReporteRepository {
  @override
  Future<List<Reporte>> getReportes() async {
    // Simulando latencia de red
    await Future.delayed(const Duration(milliseconds: 600));

    // Obtenemos los mapas desde la "base de datos" simulada
    final List<Map<String, dynamic>> rawData = BooklService().reportes;

    try {
      final List<Reporte> reportes = rawData
          .map<Reporte>((e) => ReporteDto.fromJson(e).toEntity())
          .toList();
      return reportes;
    } catch (e) {
      throw Exception('Error al parsear reportes: $e');
    }
  }
}
