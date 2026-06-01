import '../../domain/models/curso.dart';
import '../ports/out/curso_repository.dart';

class GetCursosUseCase {
  final CursoRepository repository;
  GetCursosUseCase(this.repository);

  Future<List<Curso>> call() => repository.getCursos();
}

class GetCursoByIdUseCase {
  final CursoRepository repository;
  GetCursoByIdUseCase(this.repository);

  Future<Curso?> call(int id) => repository.getCursoById(id);
}

class AddCursoUseCase {
  final CursoRepository repository;
  AddCursoUseCase(this.repository);

  Future<void> call(Curso curso) => repository.addCurso(curso);
}

class UpdateCursoUseCase {
  final CursoRepository repository;
  UpdateCursoUseCase(this.repository);

  Future<void> call(Curso curso) => repository.updateCurso(curso);
}

class DeleteCursoUseCase {
  final CursoRepository repository;
  DeleteCursoUseCase(this.repository);

  Future<void> call(int id) => repository.deleteCurso(id);
}

class GetLeccionesDeCursoUseCase {
  final CursoRepository repository;
  GetLeccionesDeCursoUseCase(this.repository);

  Future<dynamic> call(int idCurso) => repository.getLeccionesDeCurso(idCurso);
}

class AsociarLeccionACursoUseCase {
  final CursoRepository repository;
  AsociarLeccionACursoUseCase(this.repository);

  Future<void> call(int idCurso, int idLeccion) =>
      repository.asociarLeccion(idCurso, idLeccion);
}

class DesasociarLeccionDeCursoUseCase {
  final CursoRepository repository;
  DesasociarLeccionDeCursoUseCase(this.repository);

  Future<void> call(int idCurso, int idLeccion) =>
      repository.desasociarLeccion(idCurso, idLeccion);
}
