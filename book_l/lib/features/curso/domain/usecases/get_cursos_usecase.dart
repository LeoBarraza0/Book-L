import '../entities/curso.dart';
import '../repositories/curso_repository.dart';

class GetCursosUseCase {
  final CursoRepository repository;
  GetCursosUseCase(this.repository);

  Future<List<Curso>> call() => repository.getCursos();
}
