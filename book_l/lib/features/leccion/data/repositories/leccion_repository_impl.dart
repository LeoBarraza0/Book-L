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
  Future<void> addLeccion(Leccion leccion) async {
    final nueva = leccion.copyWith(idLeccion: _service.nextLeccionId());
    _service.lecciones.add(nueva);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateLeccion(Leccion leccion) async {
    final index =
        _service.lecciones.indexWhere((l) => l.idLeccion == leccion.idLeccion);
    if (index != -1) _service.lecciones[index] = leccion;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteLeccion(int id) async {
    _service.lecciones.removeWhere((l) => l.idLeccion == id);
    // Cascada: eliminar capítulos y pivote asociados
    _service.capitulos.removeWhere((c) => c.idLeccion == id);
    _service.leccionesCursos.removeWhere((e) => e['id_leccion'] == id);
  }
}
