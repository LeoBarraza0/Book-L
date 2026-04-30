import '../../domain/entities/ejercicio.dart';
import '../../domain/entities/pregunta.dart';
import '../../domain/entities/opcion.dart';
import '../../domain/repositories/ejercicio_repository.dart';
import '../../../../core/services/bookl_service.dart';

/// Implementación del repositorio de ejercicios.
/// Único punto de contacto con BooklService para esta feature.
class EjercicioRepositoryImpl implements EjercicioRepository {
  final BooklService _service = BooklService();

  @override
  Set<int> getCapituloIdsByLeccion(int idLeccion) {
    return _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .map((c) => c.idCapitulo)
        .toSet();
  }

  @override
  List<Ejercicio> getEjerciciosByCapitulos(Set<int> idsCapitulos) {
    return _service.ejercicios
        .where((e) => idsCapitulos.contains(e.idCapitulo))
        .toList();
  }

  @override
  List<int> getExerciseIdsByCapitulo(int idCapitulo) {
    return _service.ejercicios
        .where((e) => e.idCapitulo == idCapitulo)
        .map((e) => e.idEjercicio)
        .toList();
  }

  @override
  int nextEjercicioId() => _service.nextEjercicioId();

  @override
  int nextPreguntaId() => _service.nextPreguntaId();

  @override
  int nextOpcionId() => _service.nextOpcionId();

  @override
  void addEjercicio(Ejercicio ejercicio, List<Pregunta> preguntas, List<Opcion> opciones) {
    // Persiste opciones
    for (final o in opciones) {
      _service.opciones.add(o);
    }
    // Persiste preguntas
    for (final p in preguntas) {
      _service.preguntas.add(p);
    }
    // Persiste ejercicio
    _service.addEjercicio(ejercicio);
  }

  @override
  void removeEjercicio(int idEjercicio) {
    _service.removeEjercicio(idEjercicio);
  }
}
