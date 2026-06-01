import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/progreso/application/ports/out/progreso_repository.dart';

class ProgresoRepositoryImpl implements ProgresoRepository {
  final _service = BooklService();

  @override
  Future<dynamic> getProgreso(int idUsuario) async {
    // Retorna un mapa con rachas y capítulos completados
    final racha = _service.getRacha(idUsuario);
    final capitulosCompletados = AppSession().completedCapitulos.value.length;
    final ejerciciosCompletados = AppSession().completedEjercicios.value.length;

    return {
      'racha': racha?['racha_actual'] ?? 0,
      'capitulos_completados': capitulosCompletados,
      'ejercicios_completados': ejerciciosCompletados,
      'dias_actividad': racha?['dias_actividad'] ?? <String>[],
    };
  }

  @override
  Future<void> actualizarProgreso(
      int idUsuario, int idEntidad, String tipoEntidad) async {
    if (tipoEntidad == 'capitulo') {
      AppSession().marcarCapituloCompletado(idEntidad, true);

      // Sincronizar con BooklService.progresoUsuario
      final idx = _service.progresoUsuario.indexWhere((p) =>
          p['id_usuario_fk'] == idUsuario && p['id_capitulo_fk'] == idEntidad);
      if (idx != -1) {
        _service.progresoUsuario[idx]['estado'] = 'completada';
      } else {
        _service.progresoUsuario.add({
          'id_usuario_fk': idUsuario,
          'id_capitulo_fk': idEntidad,
          'estado': 'completada',
        });
      }
      _service.guardarDatos();
    } else if (tipoEntidad == 'ejercicio') {
      AppSession().marcarEjercicioCompletado(idEntidad, idUsuario);
    }
  }

  @override
  Future<void> registrarEvento(int idUsuario, String tipoEvento) async {
    _service.registrarActividad(idUsuario);
  }
}
