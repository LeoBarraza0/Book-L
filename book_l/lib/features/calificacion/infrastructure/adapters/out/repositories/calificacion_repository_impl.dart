import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/calificacion/application/ports/out/calificacion_repository.dart';
import 'package:flutter/foundation.dart';

class CalificacionRepositoryImpl implements CalificacionRepository {
  final BooklService _service = BooklService();

  @override
  Future<(double, bool)> enviarCalificacion(
      int idObjeto, String tipoObjeto, int valor) async {
    // Simulamos una demora de red (200ms) para dar tiempo a que se vea el spinner si se desea
    await Future.delayed(const Duration(milliseconds: 200));
    final idUsuarioSession = AppSession().usuarioId;
    if (idUsuarioSession == null) {
      throw Exception('Usuario no autenticado.');
    }

    if (SupabaseClientHelper.isConfigured) {
      try {
        final table = tipoObjeto == 'curso' ? 'tbl_calificacion_curso' : 'tbl_calificacion_leccion';
        final fkField = tipoObjeto == 'curso' ? 'idcursofk' : 'idleccionfk';
        final constraintCols = tipoObjeto == 'curso'
            ? 'idusuariofk,idcursofk'
            : 'idusuariofk,idleccionfk';

        // UPSERT atómico: inserta si no existe, actualiza si ya existe
        await SupabaseClientHelper.client
            .from(table)
            .upsert({
              'idusuariofk': idUsuarioSession,
              fkField: idObjeto,
              'valor': valor,
            }, onConflict: constraintCols);
      } catch (e) {
        if (kDebugMode) print('Error enviarCalificacion Supabase: $e');
      }
    }

    // Delega a BooklService (la base de datos en memoria) la persistencia de la nueva calificación
    // y el recálculo del promedio total del objeto (curso o lección).
    return await _service.agregarOActualizarCalificacion(
      idObjeto,
      tipoObjeto,
      idUsuarioSession,
      valor,
    );
  }
}
