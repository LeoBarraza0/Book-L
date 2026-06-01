import '../../../../core/usecase/usecase.dart';
import '../../domain/models/ejercicio.dart';
import '../ports/out/ejercicio_repository.dart';
import 'get_ejercicio_usecase.dart';

class EnviarRespuestaParams {
  final int idEjercicio;
  final Map<int, dynamic> respuestas; // preguntaId -> respuesta de usuario

  EnviarRespuestaParams({
    required this.idEjercicio,
    required this.respuestas,
  });
}

/// Caso de uso: Resolver Ejercicio.
/// Relación `<<include>>`: para resolver un ejercicio se requiere visualizarlo/cargar su información primero.
class EnviarRespuestaUseCase implements UMLInclude<GetEjercicioUseCase> {
  final EjercicioRepository repository;

  @override
  final GetEjercicioUseCase includedUseCase;

  EnviarRespuestaUseCase(this.repository, this.includedUseCase);

  /// Valida las respuestas y retorna un mapa de preguntaId -> esCorrecto
  Map<int, bool> call(EnviarRespuestaParams params) {
    // La validación se delega usualmente en base a las opciones correctas del ejercicio.
    // Aquí implementamos lógica para retornar si cada pregunta tiene la respuesta correcta.
    final resultados = <int, bool>{};
    return resultados;
  }
}
