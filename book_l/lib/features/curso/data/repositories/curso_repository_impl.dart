import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/curso.dart';
import '../../domain/repositories/curso_repository.dart';
import '../../../leccion/domain/entities/leccion.dart';

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
    _service.cursos.add(nuevo);
    _service.notifyDataChanged();
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCurso(Curso curso) async {
    final index =
        _service.cursos.indexWhere((c) => c.idCurso == curso.idCurso);
    if (index != -1) {
      _service.cursos[index] = curso;
      _service.notifyDataChanged();
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCurso(int id) async {
    _service.cursos.removeWhere((c) => c.idCurso == id);
    // Limpiar pivote
    _service.leccionesCursos.removeWhere((e) => e['id_curso'] == id);
    _service.notifyDataChanged();
  }

  // ── PIVOTE M:N ────────────────────────────────────────────────────────────

  @override
  Future<void> asociarLeccion(int idCurso, int idLeccion) async {
    final yaExiste = _service.leccionesCursos.any(
      (e) => e['id_curso'] == idCurso && e['id_leccion'] == idLeccion,
    );
    if (!yaExiste) {
      _service.leccionesCursos
          .add({'id_curso': idCurso, 'id_leccion': idLeccion});
    }
  }

  @override
  Future<void> desasociarLeccion(int idCurso, int idLeccion) async {
    _service.leccionesCursos.removeWhere(
      (e) => e['id_curso'] == idCurso && e['id_leccion'] == idLeccion,
    );
  }
}
