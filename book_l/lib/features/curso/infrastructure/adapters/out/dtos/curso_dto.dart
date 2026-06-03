import 'dart:convert';
import 'package:book_l/features/curso/domain/models/curso.dart';

// Único archivo autorizado a usar fromJson/toJson para Curso.
// Regla arquitectural: los DTOs traducen JSON ↔ Entity. Las entidades son Dart puro.
class CursoDto {
  static Curso fromJson(Map<String, dynamic> json) {
    return Curso(
      idCurso: (json['idcurso'] ?? json['id_curso']) as int,
      idUsuarioFk: (json['idusuariofk'] ?? json['id_usuario_fk']) as int? ?? 1,
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      imagenUrl: json['imagen_url'] as String?,
      rating: (json['rating'] ?? 0.0).toDouble(),
      duracion: json['duracion'] ?? '',
      estudiantes: json['estudiantes'] ?? 0,
      progreso: (json['progreso'] ?? 0.0).toDouble(),
      tagColor: json['tagcolor'] ?? json['tag_color'],
      esNuevo: (json['esnuevo'] ?? json['es_nuevo']) ?? true,
      estado: json['estado'] as String? ?? 'activo',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(Curso curso) {
    return {
      'idcurso': curso.idCurso,
      'idusuariofk': curso.idUsuarioFk,
      'nombre': curso.nombre,
      'contenido': curso.contenido != null
          ? jsonDecode(jsonEncode(curso.contenido))
          : null,
      'imagen_url': curso.imagenUrl,
      'rating': curso.rating,
      'duracion': curso.duracion,
      'estudiantes': curso.estudiantes,
      'progreso': curso.progreso,
      'tagcolor': curso.tagColor,
      'esnuevo': curso.esNuevo,
      'estado': curso.estado,
      'created_at': curso.createdAt?.toIso8601String(),
      'updated_at': curso.updatedAt?.toIso8601String(),
    };
  }
}
