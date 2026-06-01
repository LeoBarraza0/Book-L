import '../../../domain/models/chatbot_respuesta.dart';

/// Contrato (puerto de salida) del repositorio del chatbot.
/// Define las operaciones que la capa de datos debe implementar.
///
/// domain/ solo define la interfaz — data/ la implementa.
abstract class ChatbotRepository {
  /// Obtiene todas las intenciones/respuestas cargadas del JSON.
  Future<List<ChatbotRespuesta>> obtenerRespuestas();

  /// Busca la mejor respuesta según el mensaje del usuario.
  /// Devuelve la [ChatbotRespuesta] que mejor coincida con
  /// las palabras clave, o la respuesta por defecto si no hay match.
  Future<ChatbotRespuesta> buscarRespuesta(String mensajeUsuario);
}
