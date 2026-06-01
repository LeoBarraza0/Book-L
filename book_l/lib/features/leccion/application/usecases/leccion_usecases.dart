import '../../domain/models/leccion.dart';
import '../../domain/models/capitulo.dart';
import '../ports/out/leccion_repository.dart';
import '../ports/out/capitulo_repository.dart';
import '../../../../core/usecase/usecase.dart';

// ── Lección ────────────────────────────────────────────────────────────────

class GetLeccionesUseCase {
  final LeccionRepository repository;
  GetLeccionesUseCase(this.repository);

  Future<List<Leccion>> call() => repository.getLecciones();
}

class GetLeccionByIdUseCase
    implements UMLInclude<GetCapitulosDeLeccionUseCase> {
  final LeccionRepository repository;

  @override
  final GetCapitulosDeLeccionUseCase includedUseCase;

  GetLeccionByIdUseCase(this.repository, this.includedUseCase);

  Future<Leccion?> call(int id) async {
    final leccion = await repository.getLeccionById(id);
    if (leccion != null) {
      // Relación <<include>> ejecutada de forma explícita
      await includedUseCase(id);
    }
    return leccion;
  }
}

class AddLeccionUseCase {
  final LeccionRepository repository;
  AddLeccionUseCase(this.repository);

  Future<int> call(Leccion leccion) => repository.addLeccion(leccion);
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

  Future<int> call(Capitulo capitulo) => repository.addCapitulo(capitulo);
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
