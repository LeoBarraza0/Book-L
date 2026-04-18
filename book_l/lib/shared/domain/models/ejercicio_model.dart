class EjercicioModel {
  final String id;
  final String pregunta;
  final String tipo;

  const EjercicioModel({
    required this.id,
    required this.pregunta,
    this.tipo = 'practica',
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    return EjercicioModel(
      id: json['id'] ?? '',
      pregunta: json['pregunta'] ?? '',
      tipo: json['tipo'] ?? 'practica',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta': pregunta,
      'tipo': tipo,
    };
  }

  EjercicioModel copyWith({
    String? id,
    String? pregunta,
    String? tipo,
  }) {
    return EjercicioModel(
      id: id ?? this.id,
      pregunta: pregunta ?? this.pregunta,
      tipo: tipo ?? this.tipo,
    );
  }
}
