import '../entities/leccion.dart';
import '../entities/capitulo.dart';
import '../entities/material_educativo.dart';

// Puerto de salida para Lección — solo conoce entidades de dominio.
abstract class LeccionRepository {
  Future<List<Leccion>> getLecciones();
  Future<Leccion?> getLeccionById(int id);
  Future<int> addLeccion(Leccion leccion);
  Future<void> updateLeccion(Leccion leccion);
  Future<void> deleteLeccion(int id);

  // Resuelve Tbl_capitulo filtrada por id_leccion
  Future<List<Capitulo>> getCapitulosDeLeccion(int idLeccion);

  /// Devuelve capítulos de forma síncrona (ya cargados en memoria)
  List<Capitulo> capitulosDe(int idLeccion);

  // ── Materiales Educativos ─────────────────────────────────────────────────
  List<MaterialEducativo> materialesDeLeccion(int idLeccion);
  int agregarMaterial(MaterialEducativo material);
  void actualizarMaterial(MaterialEducativo material);
  void eliminarMaterial(int idMaterial);

  /// Genera un nuevo ID para un capítulo (delegado al servicio)
  int generarId();

  /// Obtiene un usuario por ID para mostrar info del creador
  dynamic getUsuarioById(int idUsuario);

  /// Obtiene los cursos asociados a una lección (relación N:M)
  List<dynamic> getCursosAsociados(int idLeccion);
}
