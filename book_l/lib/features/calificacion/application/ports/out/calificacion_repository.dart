abstract class CalificacionRepository {
  /// Envía una calificación para un objeto específico (lección o curso)
  /// Retorna (nuevo promedio ponderado, fue actualización)
  Future<(double, bool)> enviarCalificacion(
      int idObjeto, String tipoObjeto, int valor);
}
