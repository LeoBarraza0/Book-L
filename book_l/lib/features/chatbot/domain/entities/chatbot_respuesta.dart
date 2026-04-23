/// Entidad de dominio pura — representa una intención del chatbot
/// con sus palabras clave asociadas y posibles respuestas.
///
/// No tiene imports de Flutter ni de paquetes externos.
class ChatbotRespuesta {
  final int idIntencion;
  final String nombreIntencion;
  final List<String> palabrasClave;
  final List<String> respuestas;

  const ChatbotRespuesta({
    required this.idIntencion,
    required this.nombreIntencion,
    required this.palabrasClave,
    required this.respuestas,
  });
}
