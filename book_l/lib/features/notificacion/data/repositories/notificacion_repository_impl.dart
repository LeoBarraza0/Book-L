import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repositories/notificacion_repository.dart';
import '../dto/notificacion_dto.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  @override
  Future<List<Notificacion>> getNotificaciones(int idUsuario) async {
    // Simulando latencia
    await Future.delayed(const Duration(milliseconds: 300));
    final service = BooklService();
    final data = service.notificaciones.where((n) => n['id_usuario_fk'] == idUsuario).toList();
    
    return data.map((json) => NotificacionDto.fromJson(json).toEntity()).toList();
  }

  @override
  Future<void> marcarComoLeidas(int idUsuario) async {
    BooklService().marcarNotificacionesComoLeidas(idUsuario);
  }
}
