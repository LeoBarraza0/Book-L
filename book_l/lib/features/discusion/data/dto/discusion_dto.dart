import '../../domain/entities/discusion.dart';
import '../../domain/entities/comentario.dart';

class DiscusionDto {
  static Discusion fromJson(Map<String, dynamic> j) => Discusion(
        idDiscusion: j['id_discusion'] as int,
        idCursoFk: j['id_curso_fk'] as int?,
        idLeccionFk: j['id_leccion_fk'] as int?,
      );

  static Map<String, dynamic> toJson(Discusion d) => {
        'id_discusion': d.idDiscusion,
        'id_curso_fk': d.idCursoFk,
        'id_leccion_fk': d.idLeccionFk,
      };
}

class ComentarioDto {
  static Comentario fromJson(Map<String, dynamic> j) => Comentario(
        idComentario: j['id_comentario'] as int,
        idDiscusionFk: j['id_discusion_fk'] as int,
        idUsuarioFk: j['id_usuario_fk'] as int,
        contenido: j['contenido'] as String,
        idPadre: j['id_padre'] as int?,
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  static Map<String, dynamic> toJson(Comentario c) => {
        'id_comentario': c.idComentario,
        'id_discusion_fk': c.idDiscusionFk,
        'id_usuario_fk': c.idUsuarioFk,
        'contenido': c.contenido,
        'id_padre': c.idPadre,
        'created_at': c.createdAt.toIso8601String(),
      };
}
