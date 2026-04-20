import 'capitulo_model.dart';

class LeccionModel {
  final int id;
  final String nombre;
  final String contenido;
  final String tipo; // e.g., 'teorica', 'practica'
  final List<CapituloModel> capitulos;

  const LeccionModel({
    required this.id,
    required this.nombre,
    required this.contenido,
    this.tipo = 'teorica',
    this.capitulos = const [],
  });

  factory LeccionModel.fromJson(Map<String, dynamic> json) {
    return LeccionModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      nombre: json['nombre'] ?? json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      tipo: json['tipo'] ?? 'teorica',
      capitulos: (json['capitulos'] as List<dynamic>?)
              ?.map((e) => CapituloModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'contenido': contenido,
      'tipo': tipo,
      'capitulos': capitulos.map((e) => e.toJson()).toList(),
    };
  }

  LeccionModel copyWith({
    int? id,
    String? nombre,
    String? contenido,
    String? tipo,
    List<CapituloModel>? capitulos,
  }) {
    return LeccionModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      tipo: tipo ?? this.tipo,
      capitulos: capitulos ?? this.capitulos,
    );
  }
}
