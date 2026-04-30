import '../entities/ejercicio.dart';
import '../entities/pregunta.dart';
import '../entities/opcion.dart';

/// Puerto de dominio para la gestión de ejercicios.
abstract class EjercicioRepository {
  /// Obtiene los IDs de capítulos asociados a una lección.
  Set<int> getCapituloIdsByLeccion(int idLeccion);

  /// Obtiene todos los ejercicios de un conjunto de capítulos.
  List<Ejercicio> getEjerciciosByCapitulos(Set<int> idsCapitulos);

  /// Obtiene los IDs de ejercicios de un capítulo específico.
  List<int> getExerciseIdsByCapitulo(int idCapitulo);

  /// Genera un nuevo ID para un ejercicio.
  int nextEjercicioId();

  /// Genera un nuevo ID para una pregunta.
  int nextPreguntaId();

  /// Genera un nuevo ID para una opción.
  int nextOpcionId();

  /// Persiste un ejercicio con sus preguntas y opciones.
  void addEjercicio(Ejercicio ejercicio, List<Pregunta> preguntas, List<Opcion> opciones);

  /// Elimina un ejercicio por su ID.
  void removeEjercicio(int idEjercicio);
}
