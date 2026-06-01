import '../../../domain/models/curso.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';

// Puerto de salida (outbound port) — solo conoce entidades de dominio.
// La implementación concreta vive en data/repositories/curso_repository_impl.dart.
abstract class CursoRepository {
  Future<List<Curso>> getCursos();
  Future<Curso?> getCursoById(int id);
  Future<void> addCurso(Curso curso);
  Future<void> updateCurso(Curso curso);
  Future<void> deleteCurso(int id);

  // Resuelve la tabla pivote Tbl_lecciones_cursos
  Future<List<Leccion>> getLeccionesDeCurso(int idCurso);
  Future<void> asociarLeccion(int idCurso, int idLeccion);
  Future<void> desasociarLeccion(int idCurso, int idLeccion);
}
