import '../entities/leccion.dart';
import '../entities/capitulo.dart';
import '../repositories/leccion_repository.dart';
import '../repositories/capitulo_repository.dart';

// ── Lección ────────────────────────────────────────────────────────────────

class GetLeccionesUseCase {
  final LeccionRepository repository;
  GetLeccionesUseCase(this.repository);

  Future<List<Leccion>> call() => repository.getLecciones();
}

class GetLeccionByIdUseCase {
  final LeccionRepository repository;
  GetLeccionByIdUseCase(this.repository);

  Future<Leccion?> call(int id) => repository.getLeccionById(id);
}

class AddLeccionUseCase {
  final LeccionRepository repository;
  AddLeccionUseCase(this.repository);

  Future<void> call(Leccion leccion) => repository.addLeccion(leccion);
}

class UpdateLeccionUseCase {
  final LeccionRepository repository;
  UpdateLeccionUseCase(this.repository);

  Future<void> call(Leccion leccion) => repository.updateLeccion(leccion);
}

class DeleteLeccionUseCase {
  final LeccionRepository repository;
  DeleteLeccionUseCase(this.repository);

  Future<void> call(int id) => repository.deleteLeccion(id);
}

class GetCapitulosDeLeccionUseCase {
  final LeccionRepository repository;
  GetCapitulosDeLeccionUseCase(this.repository);

  Future<List<Capitulo>> call(int idLeccion) =>
      repository.getCapitulosDeLeccion(idLeccion);
}

// ── Capítulo ───────────────────────────────────────────────────────────────

class GetCapituloByIdUseCase {
  final CapituloRepository repository;
  GetCapituloByIdUseCase(this.repository);

  Future<Capitulo?> call(int id) => repository.getCapituloById(id);
}

class AddCapituloUseCase {
  final CapituloRepository repository;
  AddCapituloUseCase(this.repository);

  Future<void> call(Capitulo capitulo) => repository.addCapitulo(capitulo);
}

class UpdateCapituloUseCase {
  final CapituloRepository repository;
  UpdateCapituloUseCase(this.repository);

  Future<void> call(Capitulo capitulo) => repository.updateCapitulo(capitulo);
}

class DeleteCapituloUseCase {
  final CapituloRepository repository;
  DeleteCapituloUseCase(this.repository);

  Future<void> call(int id) => repository.deleteCapitulo(id);
}
