import '../../../../core/usecase/usecase.dart';
import '../../domain/models/reporte.dart';
import '../ports/out/reporte_repository.dart';

class GetReportesPorEntidadParams {
  final String tipo;
  final int id;

  GetReportesPorEntidadParams({required this.tipo, required this.id});
}

class GetReportesPorEntidadUseCase
    implements UseCase<List<Reporte>, GetReportesPorEntidadParams> {
  final ReporteRepository repository;

  GetReportesPorEntidadUseCase(this.repository);

  @override
  Future<List<Reporte>> call(GetReportesPorEntidadParams params) async {
    final reportes =
        await repository.getReportesPorEntidad(params.tipo, params.id);
    // Ordenamiento por defecto: Más recientes primero
    reportes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reportes;
  }
}
