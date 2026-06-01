import 'dart:math';

import 'package:flutter/material.dart';

import 'package:book_l/features/chatbot/application/usecases/get_respuesta_chatbot_usecase.dart';
import 'chatbot_state.dart';

/// Controller del chatbot — orquesta el estado y la lógica de la conversación.
///
/// Recibe el caso de uso inyectado (Clean Architecture), envía el mensaje
/// del usuario al use case y actualiza el estado con la respuesta del bot.
class ChatbotController extends ChangeNotifier {
  final GetRespuestaChatbotUseCase getRespuesta;
  final Random _random = Random();

  ChatbotState _state = ChatbotInitial();
  ChatbotState get state => _state;

  // Lista interna de mensajes que se mantiene a lo largo de la conversación
  final List<ChatMessage> _mensajes = [];

  ChatbotController({required this.getRespuesta});

  void _setState(ChatbotState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Envía un mensaje del usuario y obtiene la respuesta del bot.
  Future<void> enviarMensaje(String texto) async {
    final textoLimpio = texto.trim();
    if (textoLimpio.isEmpty) return;

    // 1. Agregar mensaje del usuario
    _mensajes.add(ChatMessage(texto: textoLimpio, esUsuario: true));
    _setState(ChatbotPensando(mensajes: List.from(_mensajes)));

    try {
      // 2. Buscar la mejor respuesta mediante el caso de uso
      final respuesta = await getRespuesta(textoLimpio);

      // 3. Seleccionar una respuesta aleatoria de las disponibles
      final textoRespuesta =
          respuesta.respuestas[_random.nextInt(respuesta.respuestas.length)];

      // 4. Simular un pequeño delay para que se sienta natural
      await Future.delayed(const Duration(milliseconds: 800));

      // 5. Agregar respuesta del bot
      _mensajes.add(ChatMessage(texto: textoRespuesta, esUsuario: false));
      _setState(ChatbotConversando(mensajes: List.from(_mensajes)));
    } catch (e) {
      _setState(ChatbotError(
        mensaje: e.toString(),
        mensajesPrevios: List.from(_mensajes),
      ));
    }
  }

  /// Limpia la conversación y regresa al estado inicial.
  void limpiarConversacion() {
    _mensajes.clear();
    _setState(ChatbotInitial());
  }
}
