import 'package:book_l/features/discusion/domain/models/discusion.dart';
import 'package:book_l/features/discusion/domain/models/comentario.dart';

class DiscusionDto {
  static Discusion fromJson(Map<String, dynamic> j) => Discusion(
        idDiscusion: (j['id_discusion'] ?? j['iddiscusion']) as int,
        idCursoFk: j['id_cursofk'] ?? j['id_curso_fk'],
        idLeccionFk: j['id_leccionfk'] ?? j['id_leccion_fk'],
      );

  static Map<String, dynamic> toJson(Discusion d) => {
        'id_discusion': d.idDiscusion,
        'id_cursofk': d.idCursoFk,
        'id_leccionfk': d.idLeccionFk,
      };
}

class ComentarioDto {
  static Comentario fromJson(Map<String, dynamic> j) => Comentario(
        idComentario: (j['id_comentario'] ?? j['idcomentario']) as int,
        idDiscusionFk: (j['id_discusionfk'] ?? j['id_discusion_fk']) as int,
        idUsuarioFk: (j['id_usuariofk'] ?? j['id_usuario_fk']) as int,
        contenido: j['contenido'] as String,
        idPadre: j['id_padre'] ?? j['idpadre'],
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  static Map<String, dynamic> toJson(Comentario c) => {
        'id_comentario': c.idComentario,
        'id_discusionfk': c.idDiscusionFk,
        'id_usuariofk': c.idUsuarioFk,
        'contenido': c.contenido,
        'id_padre': c.idPadre,
        'created_at': c.createdAt.toIso8601String(),
      };
}
