import 'package:flutter/material.dart';
import '../widgets/comentario_input.dart';
import '../widgets/comentario_tile.dart';

class DiscusionScreen extends StatelessWidget {
  final bool showRating; // Algunas pantallas pueden no requerir la calificacion aquí

  const DiscusionScreen({
    super.key,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const ComentarioInput(),
        const SizedBox(height: 24),
        const ComentarioTile(
          name: 'Mike Morales',
          content: 'Guao, explicas muy bien, ¿Por qué no eres profesora?',
          time: '3h',
          likes: '6 Me gusta',
        ),
        const ComentarioTile(
          name: 'Mike Morales',
          content:
              'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo...',
          time: '3h',
          likes: '6 Me gusta',
        ),
        const ComentarioTile(
          name: 'Mike Morales',
          content: 'Guao, explicas muy bien, ¿Por qué no eres profesora?',
          time: '3h',
          likes: '6 Me gusta',
        ),
        const SizedBox(height: 16),
        const Text(
          'Ver más',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
