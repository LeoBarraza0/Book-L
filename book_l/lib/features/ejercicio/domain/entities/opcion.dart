class Opcion {
  final int idOpcion;
  final int idPreguntaFk;
  final String contenido;
  final bool correcta;

  const Opcion({
    required this.idOpcion,
    required this.idPreguntaFk,
    required this.contenido,
    required this.correcta,
  });
}
