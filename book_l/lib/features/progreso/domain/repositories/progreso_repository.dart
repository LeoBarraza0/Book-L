abstract class ProgresoRepository {
  /// Obtiene los datos de progreso del usuario (por ejemplo, capítulos completados o rachas).
  Future<dynamic> getProgreso(int idUsuario);

  /// Marca una lección, curso o capítulo como completado/en progreso.
  Future<void> actualizarProgreso(int idUsuario, int idEntidad, String tipoEntidad);

  /// Registra una actividad de estudio (ej: inicio de lección) para cálculo de rachas.
  Future<void> registrarEvento(int idUsuario, String tipoEvento);
}
