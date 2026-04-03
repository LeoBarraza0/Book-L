import 'package:flutter/material.dart';

/// Header reutilizable con la imagen de fondo y el logo de BOOK-L.
/// Úsalo en las pantallas que lo requieran pasando [height].
class BookLHeader extends StatelessWidget {
  final double height;

  const BookLHeader({super.key, this.height = 420});

  static const String _bgUrl =
      'http://localhost:3845/assets/4f249115e7c6cfc36e828c251b7c4ce632f1f4c2.png';
  static const String _logoUrl =
      'http://localhost:3845/assets/e537c25c6a77635361d3fb2f09f3fe514f61e72a.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // Fondo animado con las figuras geométricas
          Positioned.fill(
            child: Image.network(
              _bgUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF0F0F0)),
            ),
          ),

          // Contenido centrado: texto + logo + tagline
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Aprende con',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Image.network(
                  _logoUrl,
                  width: 320,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'BOOK-L',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4DC130),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: const TextSpan(
                    text: 'El poder del ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                    children: [
                      TextSpan(
                        text: 'Conocimiento',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4DC130),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
