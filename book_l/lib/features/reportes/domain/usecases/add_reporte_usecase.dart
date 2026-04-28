import '../../../../core/usecase/usecase.dart';
import '../repositories/reporte_repository.dart';

class AddReporteParams {
  final int idUsuarioFk;
  final String entidadTipo;
  final int entidadId;
  final String motivo;

  AddReporteParams({
    required this.idUsuarioFk,
    required this.entidadTipo,
    required this.entidadId,
    required this.motivo,
  });
}

class AddReporteUseCase implements UseCase<void, AddReporteParams> {
  final ReporteRepository repository;

  AddReporteUseCase(this.repository);

  @override
  Future<void> call(AddReporteParams params) async {
    return await repository.addReporte(
      idUsuarioFk: params.idUsuarioFk,
      entidadTipo: params.entidadTipo,
      entidadId: params.entidadId,
      motivo: params.motivo,
    );
  }
}
