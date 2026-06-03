import 'dart:convert';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';

class CapituloDto {
  static Capitulo fromJson(Map<String, dynamic> json) {
    return Capitulo(
      idCapitulo: (json['idcapitulo'] ?? json['id_capitulo']) as int,
      idLeccion: (json['idleccion'] ?? json['id_leccion']) as int,
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      tiempoTotal: json['tiempo_total'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toJson(Capitulo capitulo) {
    return {
      'idcapitulo': capitulo.idCapitulo,
      'idleccion': capitulo.idLeccion,
      'nombre': capitulo.nombre,
      'contenido': capitulo.contenido != null
          ? jsonDecode(jsonEncode(capitulo.contenido))
          : null,
      'tiempo_total': capitulo.tiempoTotal,
      'created_at': capitulo.createdAt?.toIso8601String(),
      'updated_at': capitulo.updatedAt?.toIso8601String(),
    };
  }
}
