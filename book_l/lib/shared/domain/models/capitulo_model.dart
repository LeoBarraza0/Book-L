import 'ejercicio_model.dart';

class CapituloModel {
  final String id;
  final String titulo;
  final List<EjercicioModel> ejercicios;

  const CapituloModel({
    required this.id,
    required this.titulo,
    this.ejercicios = const [],
  });

  factory CapituloModel.fromJson(Map<String, dynamic> json) {
    return CapituloModel(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      ejercicios: (json['ejercicios'] as List<dynamic>?)
              ?.map((e) => EjercicioModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
    };
  }

  CapituloModel copyWith({
    String? id,
    String? titulo,
    List<EjercicioModel>? ejercicios,
  }) {
    return CapituloModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      ejercicios: ejercicios ?? this.ejercicios,
    );
  }
}
