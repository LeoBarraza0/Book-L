import '../entities/curso.dart';
import '../repositories/curso_repository.dart';

class GetCursoDetailUseCase {
  final CursoRepository repository;
  GetCursoDetailUseCase(this.repository);

  Future<Curso?> call(int id) => repository.getCursoById(id);
}
