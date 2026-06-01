import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';

/// Interfaz para la gestión de lecciones y cursos guardados (favoritos).
abstract class GuardadoRepository {
  /// Obtiene la lista de lecciones guardadas por el usuario actual.
  List<Leccion> getSavedLecciones();

  /// Obtiene la lista de cursos guardados por el usuario actual.
  List<Curso> getSavedCursos();

  /// Agrega o elimina una lección de los guardados.
  void toggleSavedLeccion(int idLeccion);

  /// Agrega o elimina un curso de los guardados.
  void toggleSavedCurso(int idCurso);

  /// Verifica si una lección está guardada.
  bool isLeccionSaved(int idLeccion);

  /// Verifica si un curso está guardado.
  bool isCursoSaved(int idCurso);
}
