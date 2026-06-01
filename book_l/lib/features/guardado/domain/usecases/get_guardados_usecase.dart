import '../../../leccion/domain/entities/leccion.dart';
import '../../../curso/domain/entities/curso.dart';
import '../repositories/guardado_repository.dart';

class GuardadoResult {
  final List<Leccion> lecciones;
  final List<Curso> cursos;
  GuardadoResult({required this.lecciones, required this.cursos});
}

class GetGuardadosUseCase {
  final GuardadoRepository repository;
  GetGuardadosUseCase(this.repository);

  GuardadoResult call() {
    return GuardadoResult(
      lecciones: repository.getSavedLecciones(),
      cursos: repository.getSavedCursos(),
    );
  }
}
