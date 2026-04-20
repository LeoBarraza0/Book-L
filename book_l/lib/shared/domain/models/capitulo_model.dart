import 'ejercicio_model.dart';

class CapituloModel {
  final int id;
  final String nombre;
  final List<EjercicioModel> ejercicios;
  final List<Map<String, dynamic>>? secciones;

  const CapituloModel({
    required this.id,
    required this.nombre,
    this.ejercicios = const [],
    this.secciones,
  });

  factory CapituloModel.fromJson(Map<String, dynamic> json) {
    return CapituloModel(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] ?? 0),
      nombre: json['nombre'] ?? json['titulo'] ?? '',
      ejercicios: (json['ejercicios'] as List<dynamic>?)
              ?.map((e) => EjercicioModel.fromJson(e))
              .toList() ??
          [],
      secciones: json['secciones'] != null
          ? List<Map<String, dynamic>>.from(json['secciones'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
      'secciones': secciones,
    };
  }

  CapituloModel copyWith({
    int? id,
    String? nombre,
    List<EjercicioModel>? ejercicios,
    List<Map<String, dynamic>>? secciones,
  }) {
    return CapituloModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      ejercicios: ejercicios ?? this.ejercicios,
      secciones: secciones ?? this.secciones,
    );
  }
}
