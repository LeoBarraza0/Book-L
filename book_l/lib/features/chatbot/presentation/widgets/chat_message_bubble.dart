import 'package:flutter/material.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../controller/chatbot_state.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.esUsuario) {
      // Burbuja del usuario — alineada a la derecha
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.texto,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Avatar del usuario (imagen de perfil)
            Builder(
              builder: (context) {
                final session = AppSession();
                Usuario? user;
                try {
                  user = BooklService().usuarios.firstWhere(
                        (u) => u.idUsuario == session.usuarioId,
                      );
                } catch (e) {
                  user = null;
                }
                return CircleAvatar(
                  radius: 24, // 48x48
                  backgroundColor: Colors.white,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : NetworkImage(
                              'https://ui-avatars.com/api/?name=${user?.nombreCompleto ?? 'U'}&background=random')
                          as ImageProvider,
                );
              }
            ),
          ],
        ),
      );
    } else {
      // Burbuja del bot — alineada a la izquierda
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar de Booki
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                'assets/images/Chatbot_Icon.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFDFDFDF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message.texto,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
