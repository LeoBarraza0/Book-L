import 'package:flutter/material.dart';

class ComentarioInput extends StatefulWidget {
  const ComentarioInput({super.key});

  @override
  State<ComentarioInput> createState() => _ComentarioInputState();
}

class _ComentarioInputState extends State<ComentarioInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Comentar...',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            if (_controller.text.isNotEmpty) {
              // TODO: Implementar lógica para enviar comentario
              debugPrint('Enviando comentario: ${_controller.text}');
              _controller.clear();
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF4DC130),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
