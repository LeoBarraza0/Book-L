import '../../domain/entities/leccion.dart';

class LeccionDto {
  static Leccion fromJson(Map<String, dynamic> json) {
    return Leccion(
      idLeccion: json['id_leccion'] as int,
      idUsuarioFk: json['id_usuario_fk'] as int,
      nombre: json['nombre'] as String,
      introduccion: json['introduccion'] as String?,
      estado: json['estado'] as String? ?? 'activa',
    );
  }

  static Map<String, dynamic> toJson(Leccion leccion) {
    return {
      'id_leccion': leccion.idLeccion,
      'id_usuario_fk': leccion.idUsuarioFk,
      'nombre': leccion.nombre,
      'introduccion': leccion.introduccion,
      'estado': leccion.estado,
    };
  }
}
