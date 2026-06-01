import '../../domain/models/curso.dart';
import '../ports/out/curso_repository.dart';

class GetCursosUseCase {
  final CursoRepository repository;
  GetCursosUseCase(this.repository);

  Future<List<Curso>> call() => repository.getCursos();
}
