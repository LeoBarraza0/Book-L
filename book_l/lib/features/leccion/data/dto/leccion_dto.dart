import '../../domain/entities/leccion.dart';

class LeccionDto {
  static Leccion fromJson(Map<String, dynamic> json) {
    return Leccion(
      idLeccion: json['id_leccion'] as int,
      idUsuarioFk: json['id_usuario_fk'] as int,
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      estado: json['estado'] as String? ?? 'activa',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  static Map<String, dynamic> toJson(Leccion leccion) {
    return {
      'id_leccion': leccion.idLeccion,
      'id_usuario_fk': leccion.idUsuarioFk,
      'nombre': leccion.nombre,
      'contenido': leccion.contenido,
      'estado': leccion.estado,
      'created_at': leccion.createdAt?.toIso8601String(),
      'updated_at': leccion.updatedAt?.toIso8601String(),
    };
  }
}
