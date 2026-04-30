import '../entities/notificacion.dart';

abstract class NotificacionRepository {
  Future<List<Notificacion>> getNotificaciones(int idUsuario);
  Future<void> marcarComoLeidas(int idUsuario);
}
