import 'package:flutter/material.dart';
import '../controller/discusion_controller.dart';
import '../../../../core/storage/local_storage.dart';

class ComentarioInput extends StatefulWidget {
  final DiscusionController ctrl;

  const ComentarioInput({super.key, required this.ctrl});

  @override
  State<ComentarioInput> createState() => _ComentarioInputState();
}

class _ComentarioInputState extends State<ComentarioInput> {
  late final TextEditingController _textCtrl;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController();
    widget.ctrl.addListener(_onCtrlChanged);
  }

  void _onCtrlChanged() {
    if (widget.ctrl.replyToId != null) {
      // Auto-focus al campo cuando se inicia un reply
      _focusNode.requestFocus();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_onCtrlChanged);
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _enviar() {
    if (_textCtrl.text.trim().isEmpty) return;
    widget.ctrl.agregarComentario(_textCtrl.text.trim());
    _textCtrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final myId = AppSession().usuarioId;
    final myUser = myId != null
        ? widget.ctrl.getUserSync(myId)
        : null;
    final myAvatar = myUser?.avatarUrl as String? ??
        'https://ui-avatars.com/api/?name=User&background=4DC130&color=fff';
    final isReplying = widget.ctrl.replyToId != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner de "respondiendo a..."
          if (isReplying)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFF4DC130).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply,
                      size: 14, color: Color(0xFF4DC130)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Respondiendo a ${widget.ctrl.replyToName}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.ctrl.cancelReply(),
                    child: const Icon(Icons.close,
                        size: 14, color: Color(0xFF4DC130)),
                  ),
                ],
              ),
            ),
          // Fila del input
          Row(
            children: [
              // Mi avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF4DC130),
                backgroundImage: NetworkImage(myAvatar),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 10),
              // Campo de texto
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isReplying
                          ? const Color(0xFF4DC130).withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: isReplying
                          ? 'Responde a ${widget.ctrl.replyToName}...'
                          : 'Añade un comentario...',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón de enviar
              GestureDetector(
                onTap: _enviar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DC130),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DC130).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

