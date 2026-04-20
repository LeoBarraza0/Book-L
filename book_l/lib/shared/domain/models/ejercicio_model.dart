class EjercicioModel {
  final int id;
  final String pregunta;
  final String tipo; // 'teorico' | 'practica'
  final List<String>? opciones;
  final String? respuestaCorrecta;
  final String? instrucciones;

  const EjercicioModel({
    required this.id,
    required this.pregunta,
    this.tipo = 'practica',
    this.opciones,
    this.respuestaCorrecta,
    this.instrucciones,
  });

  factory EjercicioModel.fromJson(Map<String, dynamic> json) {
    return EjercicioModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      pregunta: json['pregunta'] ?? '',
      tipo: json['tipo'] ?? 'practica',
      opciones: json['opciones'] != null ? List<String>.from(json['opciones']) : null,
      respuestaCorrecta: json['respuestaCorrecta'],
      instrucciones: json['instrucciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta': pregunta,
      'tipo': tipo,
      'opciones': opciones,
      'respuestaCorrecta': respuestaCorrecta,
      'instrucciones': instrucciones,
    };
  }

  EjercicioModel copyWith({
    int? id,
    String? pregunta,
    String? tipo,
    List<String>? opciones,
    String? respuestaCorrecta,
    String? instrucciones,
  }) {
    return EjercicioModel(
      id: id ?? this.id,
      pregunta: pregunta ?? this.pregunta,
      tipo: tipo ?? this.tipo,
      opciones: opciones ?? this.opciones,
      respuestaCorrecta: respuestaCorrecta ?? this.respuestaCorrecta,
      instrucciones: instrucciones ?? this.instrucciones,
    );
  }
}
