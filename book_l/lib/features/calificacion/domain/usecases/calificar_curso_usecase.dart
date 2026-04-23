import '../repositories/calificacion_repository.dart';

class CalificarCursoUseCase {
  final CalificacionRepository repository;

  CalificarCursoUseCase(this.repository);

  Future<(double, bool)> execute(int idCurso, int valor) async {
    return await repository.enviarCalificacion(idCurso, 'curso', valor);
  }
}
