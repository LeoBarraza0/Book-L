import '../entities/leccion.dart';
import '../repositories/leccion_repository.dart';

class CreateLeccionUseCase {
  final LeccionRepository repository;
  CreateLeccionUseCase(this.repository);

  Future<int> call(Leccion leccion) => repository.addLeccion(leccion);
}
