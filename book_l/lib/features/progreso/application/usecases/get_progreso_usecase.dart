import '../ports/out/progreso_repository.dart';

/// Caso de uso: Visualizar Progreso Académico.
/// Carga los datos de progreso y rachas del usuario.
class GetProgresoUseCase {
  final ProgresoRepository repository;
  GetProgresoUseCase(this.repository);

  /// Obtiene el progreso general del usuario.
  Future<dynamic> call(int idUsuario) => repository.getProgreso(idUsuario);
}
