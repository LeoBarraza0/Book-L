import 'opcion.dart';

class Pregunta {
  final int idPregunta;
  final int idEjercicioFk;
  final String contenido;
  final String? explicacion;
  final List<Opcion> opciones;

  const Pregunta({
    required this.idPregunta,
    required this.idEjercicioFk,
    required this.contenido,
    this.explicacion,
    this.opciones = const [],
  });
}
