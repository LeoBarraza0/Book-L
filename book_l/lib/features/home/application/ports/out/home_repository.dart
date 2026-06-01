import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import '../../../domain/models/novedad.dart';

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
