import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/curso/application/ports/out/curso_repository.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';

// Adaptador secundario — implementa el puerto definido en domain/repositories/.
// Es el único lugar en la feature curso que conoce BooklService.
class CursoRepositoryImpl implements CursoRepository {
  final BooklService _service;

  CursoRepositoryImpl(this._service);

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Curso>> getCursos() async {
    return List.unmodifiable(_service.cursos);
  }

  @override
  Future<Curso?> getCursoById(int id) async {
    try {
      return _service.cursos.firstWhere((c) => c.idCurso == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Leccion>> getLeccionesDeCurso(int idCurso) async {
    final ids = _service.leccionesCursos
        .where((e) => e['id_curso'] == idCurso)
        .map((e) => e['id_leccion']!)
        .toSet();

    return _service.lecciones.where((l) => ids.contains(l.idLeccion)).toList();
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> addCurso(Curso curso) async {
    final nuevo = curso.copyWith(idCurso: _service.nextCursoId());
    _service.addCurso(nuevo);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCurso(Curso curso) async {
    _service.updateCurso(curso);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCurso(int id) async {
    _service.removeCurso(id);
  }

  // ── PIVOTE M:N ────────────────────────────────────────────────────────────

  @override
  Future<void> asociarLeccion(int idCurso, int idLeccion) async {
    _service.asociarLeccion(idCurso, idLeccion);
  }

  @override
  Future<void> desasociarLeccion(int idCurso, int idLeccion) async {
    _service.desasociarLeccion(idCurso, idLeccion);
  }
}
