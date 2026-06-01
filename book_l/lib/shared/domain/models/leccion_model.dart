import 'capitulo_model.dart';

class LeccionModel {
  final int id;
  final int? idCursoFk;
  final String nombre;
  final String contenido;
  final String tipo; // e.g., 'teorica', 'practica'
  final List<CapituloModel> capitulos;
  final double rating;
  final String duracion;
  final int estudiantes;
  final double progreso;
  final int? tagColor;
  final bool esNuevo;

  const LeccionModel({
    required this.id,
    this.idCursoFk,
    required this.nombre,
    required this.contenido,
    this.tipo = 'teorica',
    this.capitulos = const [],
    this.rating = 0.0,
    this.duracion = '',
    this.estudiantes = 0,
    this.progreso = 0.0,
    this.tagColor,
    this.esNuevo = true,
  });

  factory LeccionModel.fromJson(Map<String, dynamic> json) {
    return LeccionModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),
      idCursoFk: json['id_curso_fk'] ?? json['cursoId'],
      nombre: json['nombre'] ?? json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      tipo: json['tipo'] ?? 'teorica',
      capitulos: (json['capitulos'] as List<dynamic>?)
              ?.map((e) => CapituloModel.fromJson(e))
              .toList() ??
          [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      duracion: json['duracion'] ?? '',
      estudiantes: json['estudiantes'] ?? 0,
      progreso: (json['progreso'] ?? 0.0).toDouble(),
      tagColor: json['tag_color'],
      esNuevo: json['es_nuevo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_curso_fk': idCursoFk,
      'nombre': nombre,
      'contenido': contenido,
      'tipo': tipo,
      'capitulos': capitulos.map((e) => e.toJson()).toList(),
      'rating': rating,
      'duracion': duracion,
      'estudiantes': estudiantes,
      'progreso': progreso,
      'tag_color': tagColor,
      'es_nuevo': esNuevo,
    };
  }

  LeccionModel copyWith({
    int? id,
    int? idCursoFk,
    String? nombre,
    String? contenido,
    String? tipo,
    List<CapituloModel>? capitulos,
    double? rating,
    String? duracion,
    int? estudiantes,
    double? progreso,
    int? tagColor,
    bool? esNuevo,
  }) {
    return LeccionModel(
      id: id ?? this.id,
      idCursoFk: idCursoFk ?? this.idCursoFk,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      tipo: tipo ?? this.tipo,
      capitulos: capitulos ?? this.capitulos,
      rating: rating ?? this.rating,
      duracion: duracion ?? this.duracion,
      estudiantes: estudiantes ?? this.estudiantes,
      progreso: progreso ?? this.progreso,
      tagColor: tagColor ?? this.tagColor,
      esNuevo: esNuevo ?? this.esNuevo,
    );
  }
}
