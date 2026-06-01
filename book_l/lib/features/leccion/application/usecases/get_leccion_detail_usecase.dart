import '../../domain/models/leccion.dart';
import '../ports/out/leccion_repository.dart';

class GetLeccionDetailUseCase {
  final LeccionRepository repository;
  GetLeccionDetailUseCase(this.repository);

  Future<Leccion?> call(int id) => repository.getLeccionById(id);
}
