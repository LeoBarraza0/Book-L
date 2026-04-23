import '../../../../core/usecase/usecase.dart';
import '../entities/chatbot_respuesta.dart';
import '../repositories/chatbot_repository.dart';

/// Caso de uso: Obtener la respuesta del chatbot dado un mensaje del usuario.
///
/// Recibe el texto del usuario, busca la mejor coincidencia por palabras clave
/// y devuelve la intención con sus respuestas posibles.
class GetRespuestaChatbotUseCase extends UseCase<ChatbotRespuesta, String> {
  final ChatbotRepository repository;

  GetRespuestaChatbotUseCase(this.repository);

  /// [params] es el mensaje del usuario en texto plano.
  @override
  Future<ChatbotRespuesta> call(String params) {
    return repository.buscarRespuesta(params);
  }
}
