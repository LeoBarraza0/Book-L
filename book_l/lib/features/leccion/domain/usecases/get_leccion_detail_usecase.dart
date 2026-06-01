import '../entities/leccion.dart';
import '../repositories/leccion_repository.dart';

class GetLeccionDetailUseCase {
  final LeccionRepository repository;
  GetLeccionDetailUseCase(this.repository);

  Future<Leccion?> call(int id) => repository.getLeccionById(id);
}
