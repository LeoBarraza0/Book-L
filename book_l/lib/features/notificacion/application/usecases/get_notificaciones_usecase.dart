import '../../../../core/usecase/usecase.dart';
import '../../domain/models/notificacion.dart';
import '../ports/out/notificacion_repository.dart';

class GetNotificacionesUseCase implements UseCase<List<Notificacion>, int> {
  final NotificacionRepository repository;

  GetNotificacionesUseCase(this.repository);

  @override
  Future<List<Notificacion>> call(int idUsuario) async {
    return await repository.getNotificaciones(idUsuario);
  }
}
