import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:book_l/features/chatbot/domain/models/chatbot_respuesta.dart';
import 'package:book_l/features/chatbot/application/ports/out/chatbot_repository.dart';
import 'package:book_l/features/chatbot/infrastructure/adapters/out/dtos/chatbot_respuesta_dto.dart';

/// Implementación concreta del repositorio del chatbot.
///
/// Flujo de datos:
/// Al ser datos estáticos de configuración (intenciones del bot), el repositorio
/// lee directamente del archivo JSON local sin pasar por BooklService (que está
/// reservado para datos transaccionales en memoria). Las respuestas se parsean
/// a través de DTOs y se mapean a Entidades de Dominio puras.
class ChatbotRepositoryImpl implements ChatbotRepository {
  // Cache en memoria para no leer el JSON en cada mensaje
  List<ChatbotRespuesta>? _cache;

  /// Carga las respuestas desde el JSON de assets y las cachea.
  @override
  Future<List<ChatbotRespuesta>> obtenerRespuestas() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/data/bookl_data.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    if (data.containsKey('chatbot_respuestas')) {
      final dtos = (data['chatbot_respuestas'] as List)
          .map((e) => ChatbotRespuestaDto.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache = dtos.map((dto) => dto.toEntity()).toList();
    } else {
      _cache = [];
    }

    return _cache!;
  }

  /// Algoritmo de matching por palabras clave:
  ///
  /// 1. Normaliza el mensaje del usuario (minúsculas, sin acentos extra).
  /// 2. Recorre cada intención y cuenta cuántas palabras clave coinciden.
  /// 3. Devuelve la intención con mayor número de coincidencias.
  /// 4. Si no hay coincidencias, devuelve la intención "respuesta_por_defecto".
  @override
  Future<ChatbotRespuesta> buscarRespuesta(String mensajeUsuario) async {
    final respuestas = await obtenerRespuestas();
    final mensajeNormalizado = _normalizar(mensajeUsuario);

    ChatbotRespuesta? mejorCoincidencia;
    int mejorPuntaje = 0;

    for (final respuesta in respuestas) {
      // Ignorar la respuesta por defecto en la búsqueda activa
      if (respuesta.palabrasClave.isEmpty) continue;

      int puntaje = 0;
      for (final palabra in respuesta.palabrasClave) {
        final palabraNormalizada = _normalizar(palabra);
        if (mensajeNormalizado.contains(palabraNormalizada)) {
          puntaje++;
        }
      }

      if (puntaje > mejorPuntaje) {
        mejorPuntaje = puntaje;
        mejorCoincidencia = respuesta;
      }
    }

    // Si no hubo coincidencia, usar la respuesta por defecto
    mejorCoincidencia ??= respuestas.firstWhere(
      (r) => r.nombreIntencion == 'respuesta_por_defecto',
      orElse: () => const ChatbotRespuesta(
        idIntencion: 0,
        nombreIntencion: 'fallback',
        palabrasClave: [],
        respuestas: ['Lo siento, no puedo responder a eso en este momento.'],
      ),
    );

    return mejorCoincidencia;
  }

  /// Normaliza un texto: minúsculas y elimina caracteres especiales innecesarios.
  String _normalizar(String texto) {
    return texto.toLowerCase().trim();
  }
}
