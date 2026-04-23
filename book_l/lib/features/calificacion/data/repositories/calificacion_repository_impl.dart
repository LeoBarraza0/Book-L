import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/repositories/calificacion_repository.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final BooklService _service = BooklService();

  @override
  Future<(double, bool)> enviarCalificacion(int idObjeto, String tipoObjeto, int valor) async {
    // Simulamos una demora de red (200ms) para dar tiempo a que se vea el spinner si se desea
    await Future.delayed(const Duration(milliseconds: 200));
    final idUsuarioSession = AppSession().usuarioId ?? 1;

    // Delegate a BooklService persistencia y recálculo
    return await _service.agregarOActualizarCalificacion(
      idObjeto,
      tipoObjeto,
      idUsuarioSession,
      valor,
    );
  }
}
