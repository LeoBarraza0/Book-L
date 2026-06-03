import 'package:book_l/features/discusion/domain/models/comentario.dart';

class ComentarioDto {
  static Comentario fromJson(Map<String, dynamic> json) {
    return Comentario(
      idComentario: (json['id_comentario'] ?? 0) as int,
      idDiscusionFk: (json['id_discusionfk'] ?? 0) as int,
      idUsuarioFk: (json['id_usuariofk'] ?? 0) as int,
      contenido: json['contenido'] as String,
      idPadre: json['id_padre'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> toJson(Comentario c) {
    return {
      if (c.idComentario != 0) 'id_comentario': c.idComentario,
      'id_discusionfk': c.idDiscusionFk,
      'id_usuariofk': c.idUsuarioFk,
      'contenido': c.contenido,
      'id_padre': c.idPadre,
    };
  }
}
