import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/notificacion/domain/models/notificacion.dart';
import 'package:book_l/features/notificacion/application/ports/out/notificacion_repository.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/out/dtos/notificacion_dto.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  @override
  Future<List<Notificacion>> getNotificaciones(int idUsuario) async {
    // Simulando latencia
    await Future.delayed(const Duration(milliseconds: 300));
    final service = BooklService();
    final data = service.notificaciones
        .where((n) => n['id_usuario_fk'] == idUsuario)
        .toList();

    return data
        .map((json) => NotificacionDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> marcarComoLeidas(int idUsuario) async {
    BooklService().marcarNotificacionesComoLeidas(idUsuario);
  }
}
