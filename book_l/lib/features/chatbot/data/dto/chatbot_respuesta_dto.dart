import '../../domain/entities/chatbot_respuesta.dart';

/// DTO — Traduce entre JSON y la entidad de dominio ChatbotRespuesta.
///
/// Solo este archivo puede usar fromJson/toJson (regla arquitectural).
class ChatbotRespuestaDto {
  final int idIntencion;
  final String nombreIntencion;
  final List<String> palabrasClave;
  final List<String> respuestas;

  ChatbotRespuestaDto({
    required this.idIntencion,
    required this.nombreIntencion,
    required this.palabrasClave,
    required this.respuestas,
  });

  /// Construye el DTO desde un mapa JSON del bookl_data.json
  factory ChatbotRespuestaDto.fromJson(Map<String, dynamic> json) {
    return ChatbotRespuestaDto(
      idIntencion: json['id_intencion'] as int,
      nombreIntencion: json['nombre_intencion'] as String,
      palabrasClave: List<String>.from(json['palabras_clave'] ?? []),
      respuestas: List<String>.from(json['respuestas'] ?? []),
    );
  }

  /// Convierte a la entidad de dominio pura (sin JSON)
  ChatbotRespuesta toEntity() {
    return ChatbotRespuesta(
      idIntencion: idIntencion,
      nombreIntencion: nombreIntencion,
      palabrasClave: palabrasClave,
      respuestas: respuestas,
    );
  }
}
