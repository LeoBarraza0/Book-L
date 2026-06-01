import '../entities/leccion.dart';
import '../repositories/leccion_repository.dart';

class GetLeccionesUseCase {
  final LeccionRepository repository;
  GetLeccionesUseCase(this.repository);

  Future<List<Leccion>> call() => repository.getLecciones();
}
