import '../../../../core/usecase/usecase.dart';
import '../entities/notificacion.dart';
import '../repositories/notificacion_repository.dart';

class GetNotificacionesUseCase implements UseCase<List<Notificacion>, int> {
  final NotificacionRepository repository;

  GetNotificacionesUseCase(this.repository);

  @override
  Future<List<Notificacion>> call(int idUsuario) async {
    return await repository.getNotificaciones(idUsuario);
  }
}
