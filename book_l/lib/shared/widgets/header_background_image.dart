import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable que muestra la imagen de portada subida por el usuario
/// en el header, o cae al placeholder por defecto si no se subió imagen.
///
/// [imagenUrl] — path local o URL de la imagen subida (puede ser null).
/// [fallbackAsset] — asset por defecto ('green_bg.png' o 'red_bg.png').
/// [fallbackColor] — color de fondo si el asset falla.
class HeaderBackgroundImage extends StatelessWidget {
  final String? imagenUrl;
  final String fallbackAsset;
  final Color fallbackColor;

  const HeaderBackgroundImage({
    super.key,
    this.imagenUrl,
    this.fallbackAsset = 'assets/images/green_bg.png',
    this.fallbackColor = const Color(0xFF4DC130),
  });

  @override
  Widget build(BuildContext context) {
    final url = imagenUrl;

    // Si hay imagen subida, mostrarla
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http')) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
      if (url.startsWith('assets/')) {
        return Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
      // Path local (archivo del dispositivo)
      if (!kIsWeb) {
        return Image.file(
          File(url),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      }
    }

    // Fallback: placeholder por defecto
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Transform.scale(
      scale: 1.15,
      child: Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: fallbackColor),
      ),
    );
  }
}
