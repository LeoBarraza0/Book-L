import '../../domain/entities/curso.dart';

// Único archivo autorizado a usar fromJson/toJson para Curso.
// Regla arquitectural: los DTOs traducen JSON ↔ Entity. Las entidades son Dart puro.
class CursoDto {
  static Curso fromJson(Map<String, dynamic> json) {
    return Curso(
      idCurso: json['id_curso'] as int,
      idUsuarioFk: json['id_usuario_fk'] as int? ?? 1, // Default 1 (Emanuel) si falta
      nombre: json['nombre'] as String,
      introduccion: json['introduccion'] as String?,
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  static Map<String, dynamic> toJson(Curso curso) {
    return {
      'id_curso': curso.idCurso,
      'id_usuario_fk': curso.idUsuarioFk,
      'nombre': curso.nombre,
      'introduccion': curso.introduccion,
      'estado': curso.estado,
    };
  }
}
