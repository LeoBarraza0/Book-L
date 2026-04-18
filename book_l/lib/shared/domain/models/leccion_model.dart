import 'capitulo_model.dart';

class LeccionModel {
  final String id;
  final String titulo;
  final String contenido;
  final String tipo; // e.g., 'teorica', 'practica'
  final List<CapituloModel> capitulos;

  const LeccionModel({
    required this.id,
    required this.titulo,
    required this.contenido,
    this.tipo = 'teorica',
    this.capitulos = const [],
  });

  factory LeccionModel.fromJson(Map<String, dynamic> json) {
    return LeccionModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
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
      'titulo': titulo,
      'contenido': contenido,
      'tipo': tipo,
      'capitulos': capitulos.map((e) => e.toJson()).toList(),
    };
  }

  LeccionModel copyWith({
    String? id,
    String? titulo,
    String? contenido,
    String? tipo,
    List<CapituloModel>? capitulos,
  }) {
    return LeccionModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      tipo: tipo ?? this.tipo,
      capitulos: capitulos ?? this.capitulos,
    );
  }
}
