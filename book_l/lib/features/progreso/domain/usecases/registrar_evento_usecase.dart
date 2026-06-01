import '../repositories/progreso_repository.dart';

/// Caso de uso: Registrar Evento de Aprendizaje.
/// Registra una actividad de estudio para el cálculo de rachas.
class RegistrarEventoUseCase {
  final ProgresoRepository repository;
  RegistrarEventoUseCase(this.repository);

  Future<void> call(int idUsuario, String tipoEvento) =>
      repository.registrarEvento(idUsuario, tipoEvento);
}
