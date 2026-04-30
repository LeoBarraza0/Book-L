import '../../../../features/curso/domain/entities/curso.dart';
import '../../../../features/leccion/domain/entities/leccion.dart';
import '../entities/novedad.dart';

abstract class HomeRepository {
  /// Obtiene la lista de lecciones que están activas para la pantalla de Home (FYP).
  List<Leccion> getLeccionesActivas();

  /// Obtiene la lista de cursos que están publicados para la pantalla de Home (FYP).
  List<Curso> getCursosPublicados();

  /// Obtiene las novedades recientes (Cursos, Lecciones, Capítulos) para el panel Admin.
  Future<List<Novedad>> getNovedades();

  /// Obtiene la racha de actividad del usuario.
  Map<String, dynamic>? getRacha(int userId);
}
