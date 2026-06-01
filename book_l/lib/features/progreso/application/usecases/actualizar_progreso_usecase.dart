import '../ports/out/progreso_repository.dart';

/// Caso de uso: Actualizar Progreso.
/// Postcondición del sistema ejecutada tras completar lecciones o ejercicios.
class ActualizarProgresoUseCase {
  final ProgresoRepository repository;
  ActualizarProgresoUseCase(this.repository);

  Future<void> call(int idUsuario, int idEntidad, String tipoEntidad) =>
      repository.actualizarProgreso(idUsuario, idEntidad, tipoEntidad);
}
