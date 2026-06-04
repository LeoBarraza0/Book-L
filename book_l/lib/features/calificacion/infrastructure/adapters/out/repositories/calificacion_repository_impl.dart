import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/calificacion/application/ports/out/calificacion_repository.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final BooklService _service = BooklService();

  @override
  Future<(double, bool)> enviarCalificacion(
      int idObjeto, String tipoObjeto, int valor) async {
    final idUsuarioSession = AppSession().usuarioId;
    if (idUsuarioSession == null) {
      throw Exception('Usuario no autenticado.');
    }

    // Delega a BooklService: actualiza memoria, recalcula promedio y sincroniza con Supabase
    return await _service.agregarOActualizarCalificacion(
      idObjeto,
      tipoObjeto,
      idUsuarioSession,
      valor,
    );
  }
}
