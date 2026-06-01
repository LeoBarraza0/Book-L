import '../../domain/models/ejercicio.dart';
import '../ports/out/ejercicio_repository.dart';

class GetEjercicioUseCase {
  final EjercicioRepository repository;
  GetEjercicioUseCase(this.repository);

  List<Ejercicio> call(int idLeccion) {
    final capituloIds = repository.getCapituloIdsByLeccion(idLeccion);
    return repository.getEjerciciosByCapitulos(capituloIds);
  }
}
