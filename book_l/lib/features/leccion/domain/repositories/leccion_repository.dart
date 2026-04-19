import '../entities/leccion.dart';
import '../entities/capitulo.dart';

// Puerto de salida para Lección — solo conoce entidades de dominio.
abstract class LeccionRepository {
  Future<List<Leccion>> getLecciones();
  Future<Leccion?> getLeccionById(int id);
  Future<void> addLeccion(Leccion leccion);
  Future<void> updateLeccion(Leccion leccion);
  Future<void> deleteLeccion(int id);

  // Resuelve Tbl_capitulo filtrada por id_leccion
  Future<List<Capitulo>> getCapitulosDeLeccion(int idLeccion);
}
