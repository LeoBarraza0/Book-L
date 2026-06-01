import 'package:book_l/features/leccion/domain/models/leccion.dart';

class LeccionDto {
  static Leccion fromJson(Map<String, dynamic> json) {
    return Leccion(
      idLeccion: json['id_leccion'] as int,
      idUsuarioFk: json['id_usuario_fk'] as int,
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      imagenUrl: json['imagen_url'] as String?,
      rating: (json['rating'] ?? 0.0).toDouble(),
      duracion: json['duracion'] ?? '',
      estudiantes: json['estudiantes'] ?? 0,
      progreso: (json['progreso'] ?? 0.0).toDouble(),
      tagColor: json['tag_color'],
      esNuevo: json['es_nuevo'] ?? true,
      estado: json['estado'] as String? ?? 'activa',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(Leccion leccion) {
    return {
      'id_leccion': leccion.idLeccion,
      'id_usuario_fk': leccion.idUsuarioFk,
      'nombre': leccion.nombre,
      'contenido': leccion.contenido,
      'imagen_url': leccion.imagenUrl,
      'rating': leccion.rating,
      'duracion': leccion.duracion,
      'estudiantes': leccion.estudiantes,
      'progreso': leccion.progreso,
      'tag_color': leccion.tagColor,
      'es_nuevo': leccion.esNuevo,
      'estado': leccion.estado,
      'created_at': leccion.createdAt?.toIso8601String(),
      'updated_at': leccion.updatedAt?.toIso8601String(),
    };
  }
}
