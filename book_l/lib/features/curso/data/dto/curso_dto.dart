import '../../domain/entities/curso.dart';

// Único archivo autorizado a usar fromJson/toJson para Curso.
// Regla arquitectural: los DTOs traducen JSON ↔ Entity. Las entidades son Dart puro.
class CursoDto {
  static Curso fromJson(Map<String, dynamic> json) {
    return Curso(
      idCurso: json['id_curso'] as int,
      idUsuarioFk: json['id_usuario_fk'] as int? ?? 1, // Default 1 (Emanuel) si falta
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      estado: json['estado'] as String? ?? 'activo',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  static Map<String, dynamic> toJson(Curso curso) {
    return {
      'id_curso': curso.idCurso,
      'id_usuario_fk': curso.idUsuarioFk,
      'nombre': curso.nombre,
      'contenido': curso.contenido,
      'estado': curso.estado,
      'created_at': curso.createdAt?.toIso8601String(),
      'updated_at': curso.updatedAt?.toIso8601String(),
    };
  }
}
