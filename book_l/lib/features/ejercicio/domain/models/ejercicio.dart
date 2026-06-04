import 'pregunta.dart';

enum TipoEjercicio {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  ordenar('ordenar'),
  rellenar('rellenar'),
  respuestaCorta('respuesta_corta');

  final String name;
  const TipoEjercicio(this.name);

  static TipoEjercicio fromString(String value) {
    // Match by custom 'name' field first (e.g. 'true_false'),
    // then fall back to matching the Dart enum member identifier (e.g. 'trueFalse').
    final normalized = value.trim().toLowerCase();
    return TipoEjercicio.values.firstWhere(
      (e) => e.name == value || e.name.toLowerCase() == normalized,
      orElse: () => TipoEjercicio.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
        orElse: () => TipoEjercicio.multipleChoice,
      ),
    );
  }

  String get displayName {
    switch (this) {
      case TipoEjercicio.multipleChoice:
        return 'Opción Múltiple';
      case TipoEjercicio.trueFalse:
        return 'Falso/Verdadero';
      case TipoEjercicio.ordenar:
        return 'Ordenar';
      case TipoEjercicio.rellenar:
        return 'Rellenar';
      case TipoEjercicio.respuestaCorta:
        return 'Resp. Corta';
    }
  }
}

class Ejercicio {
  final int idEjercicio;
  final int idCapitulo;
  final TipoEjercicio tipo;
  final String titulo;
  final String descripcion;
  final List<Pregunta> preguntas;

  const Ejercicio({
    required this.idEjercicio,
    required this.idCapitulo,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    this.preguntas = const [],
  });
}
