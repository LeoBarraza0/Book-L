import '../entities/discusion.dart';
import '../entities/comentario.dart';

abstract class DiscusionRepository {
  /// Obtiene o crea la discusión para un curso o lección.
  Discusion obtenerOCrearDiscusion({int? idCurso, int? idLeccion});

  /// Obtiene todos los comentarios raíz (sin padre) de una discusión.
  List<Comentario> getComentariosRaiz(int idDiscusion);

  /// Obtiene las respuestas de un comentario padre.
  List<Comentario> getRespuestas(int idComentarioPadre);

  /// Agrega un comentario o respuesta.
  Comentario agregarComentario({
    required int idDiscusion,
    required int idUsuario,
    required String contenido,
    int? idPadre,
  });

  /// Obtiene la información de usuario de forma síncrona
  dynamic getUserSync(int idUsuario);
}
