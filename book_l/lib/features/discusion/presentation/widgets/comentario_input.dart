import 'package:flutter/material.dart';

class ComentarioInput extends StatelessWidget {
  const ComentarioInput({super.key});

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
            child: const Text('Comentar...', style: TextStyle(color: Colors.black54, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF4DC130),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
