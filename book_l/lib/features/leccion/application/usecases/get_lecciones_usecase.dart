import '../../domain/models/leccion.dart';
import '../ports/out/leccion_repository.dart';

class GetLeccionesUseCase {
  final LeccionRepository repository;
  GetLeccionesUseCase(this.repository);

  Future<List<Leccion>> call() => repository.getLecciones();
}
