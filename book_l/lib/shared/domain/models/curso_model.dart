import 'package:flutter/material.dart';
import 'leccion_model.dart';

class CursoModel {
  final int id;
  final String nombre;
  final String descripcion;
  final List<String> tags; // e.g. ['JAVA', 'OOP']
  final double rating;
  final String duracion; // e.g. '1 Hora'
  final int estudiantes;
  final double progreso; // 0.0 to 1.0
  final Color tagColor;
  final bool esNuevo;
  final List<LeccionModel> lecciones;
  final int idUsuarioFk;

  const CursoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.tags = const [],
    this.rating = 0.0,
    this.duracion = '',
    this.estudiantes = 0,
    this.progreso = 0.0,
    this.tagColor = const Color(0xFF4DC130),
    this.esNuevo = true,
    this.lecciones = const [],
    this.idUsuarioFk = 0,
  });

  factory CursoModel.fromJson(Map<String, dynamic> json) {
    return CursoModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      nombre: json['nombre'] ?? json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      duracion: json['duracion'] ?? '',
      estudiantes: json['estudiantes'] ?? 0,
      progreso: (json['progreso'] ?? 0.0).toDouble(),
      tagColor: json['tagColor'] != null ? Color(json['tagColor']) : const Color(0xFF4DC130),
      esNuevo: json['esNuevo'] ?? false,
      lecciones: (json['lecciones'] as List<dynamic>?)
              ?.map((e) => LeccionModel.fromJson(e))
              .toList() ??
          [],
      idUsuarioFk: json['id_usuario_fk'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tags': tags,
      'rating': rating,
      'duracion': duracion,
      'estudiantes': estudiantes,
      'progreso': progreso,
      'tagColor': tagColor.value,
      'esNuevo': esNuevo,
      'lecciones': lecciones.map((e) => e.toJson()).toList(),
      'id_usuario_fk': idUsuarioFk,
    };
  }

  CursoModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    List<String>? tags,
    double? rating,
    String? duracion,
    int? estudiantes,
    double? progreso,
    Color? tagColor,
    bool? esNuevo,
    List<LeccionModel>? lecciones,
    int? idUsuarioFk,
  }) {
    return CursoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      duracion: duracion ?? this.duracion,
      estudiantes: estudiantes ?? this.estudiantes,
      progreso: progreso ?? this.progreso,
      tagColor: tagColor ?? this.tagColor,
      esNuevo: esNuevo ?? this.esNuevo,
      lecciones: lecciones ?? this.lecciones,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
    );
  }
}
