import '../../../../core/usecase/usecase.dart';
import '../../domain/models/reporte_agrupado.dart';
import '../ports/out/reporte_repository.dart';

class GetReportesAgrupadosUseCase
    implements UseCase<List<ReporteAgrupado>, NoParams> {
  final ReporteRepository repository;

  GetReportesAgrupadosUseCase(this.repository);

  @override
  Future<List<ReporteAgrupado>> call(NoParams params) async {
    return await repository.getReportesAgrupados();
  }
}
