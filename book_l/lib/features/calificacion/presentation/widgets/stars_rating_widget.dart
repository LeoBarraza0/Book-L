import 'package:flutter/material.dart';

class StarsRatingWidget extends StatelessWidget {
  const StarsRatingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Tu calificación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => const Icon(Icons.star_border, color: Colors.black45, size: 36)),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: const Text(
            '¡Enviar!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
