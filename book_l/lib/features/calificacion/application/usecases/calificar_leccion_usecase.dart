import '../ports/out/calificacion_repository.dart';

class CalificarLeccionUseCase {
  final CalificacionRepository repository;

  CalificarLeccionUseCase(this.repository);

  Future<(double, bool)> execute(int idLeccion, int valor) async {
    return await repository.enviarCalificacion(idLeccion, 'leccion', valor);
  }
}
