import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/leccion.dart';
import '../../domain/entities/capitulo.dart';
import '../../domain/repositories/leccion_repository.dart';

class LeccionRepositoryImpl implements LeccionRepository {
  final BooklService _service;

  LeccionRepositoryImpl(this._service);

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Leccion>> getLecciones() async {
    return List.unmodifiable(_service.lecciones);
  }

  @override
  Future<Leccion?> getLeccionById(int id) async {
    try {
      return _service.lecciones.firstWhere((l) => l.idLeccion == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Capitulo>> getCapitulosDeLeccion(int idLeccion) async {
    return _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .toList();
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<int> addLeccion(Leccion leccion) async {
    final newId = _service.nextLeccionId();
    final nueva = leccion.copyWith(idLeccion: newId);
    _service.addLeccion(nueva);
    return newId;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateLeccion(Leccion leccion) async {
    _service.updateLeccion(leccion);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteLeccion(int id) async {
    _service.removeLeccion(id);
  }
}
