/// Modelo de un mensaje individual en el chat.
class ChatMessage {
  final String texto;
  final bool esUsuario;
  final DateTime timestamp;

  ChatMessage({
    required this.texto,
    required this.esUsuario,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Estados posibles de la pantalla del chatbot.
///
/// Sigue el patrón de estados del proyecto (ver admin_home_state.dart).
abstract class ChatbotState {}

/// Estado inicial — sin mensajes, se muestra la vista de bienvenida.
class ChatbotInitial extends ChatbotState {}

/// Estado activo — hay mensajes en la conversación.
class ChatbotConversando extends ChatbotState {
  final List<ChatMessage> mensajes;

  ChatbotConversando({required this.mensajes});
}

/// Estado de carga — el bot está "pensando" una respuesta.
class ChatbotPensando extends ChatbotState {
  final List<ChatMessage> mensajes;

  ChatbotPensando({required this.mensajes});
}

/// Estado de error — algo falló al obtener la respuesta.
class ChatbotError extends ChatbotState {
  final String mensaje;
  final List<ChatMessage> mensajesPrevios;

  ChatbotError({required this.mensaje, required this.mensajesPrevios});
}
