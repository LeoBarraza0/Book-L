import '../../../domain/models/discusion.dart';
import '../../../domain/models/comentario.dart';

abstract class DiscusionRepository {
  /// Obtiene o crea la discusión para un curso o lección.
  Future<Discusion> obtenerOCrearDiscusion({int? idCurso, int? idLeccion});

  /// Obtiene todos los comentarios raíz (sin padre) de una discusión.
  Future<List<Comentario>> getComentariosRaiz(int idDiscusion);

  /// Obtiene las respuestas de un comentario padre.
  Future<List<Comentario>> getRespuestas(int idComentarioPadre);

  /// Agrega un comentario o respuesta.
  Future<Comentario> agregarComentario({
    required int idDiscusion,
    required int idUsuario,
    required String contenido,
    int? idPadre,
  });

  /// Obtiene la información de usuario de forma síncrona
  dynamic getUserSync(int idUsuario);
}
