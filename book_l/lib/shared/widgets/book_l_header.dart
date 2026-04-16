import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Header reutilizable con la imagen de fondo y el logo de BOOK-L.
/// Úsalo en las pantallas que lo requieran pasando [height].
class BookLHeader extends StatelessWidget {
  final double height;

  const BookLHeader({super.key, this.height = 420});

  static const String _bgPath = 'assets/images/Fondo_Blanco.png';
  static const String _logoPath = 'assets/images/logo.svg';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // Fondo animado con las figuras geométricas
          Positioned.fill(
            child: Image.asset(
              _bgPath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: const Color(0xFFF0F0F0)),
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
                SvgPicture.asset(
                  _logoPath,
                  width: 400,
                  height: 160,
                  fit: BoxFit.contain,
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
