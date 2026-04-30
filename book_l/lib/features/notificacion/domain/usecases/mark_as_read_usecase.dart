import '../../../../core/usecase/usecase.dart';
import '../repositories/notificacion_repository.dart';

class MarkAsReadUseCase implements UseCase<void, int> {
  final NotificacionRepository repository;

  MarkAsReadUseCase(this.repository);

  @override
  Future<void> call(int idUsuario) async {
    await repository.marcarComoLeidas(idUsuario);
  }
}
