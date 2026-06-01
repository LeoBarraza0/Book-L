import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? url;
  final String nombre;
  final double radius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const CustomAvatar({
    super.key,
    required this.url,
    required this.nombre,
    this.radius = 25,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? const Color(0xFFF0F0F0);

    // Generar iniciales de forma robusta
    final tokens = nombre.trim().split(' ').where((s) => s.isNotEmpty).toList();
    String iniciales = '?';
    if (tokens.length >= 2) {
      iniciales = '${tokens[0][0]}${tokens[1][0]}'.toUpperCase();
    } else if (tokens.isNotEmpty) {
      iniciales = tokens[0][0].toUpperCase();
    }

    Widget avatarChild;

    if (url != null && url!.isNotEmpty) {
      if (kIsWeb || url!.startsWith('http') || url!.startsWith('https')) {
        avatarChild = Image.network(
          url!,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(iniciales);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DC130)),
                ),
              ),
            );
          },
        );
      } else {
        avatarChild = Image.file(
          File(url!),
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallback(iniciales);
          },
        );
      }
    } else {
      avatarChild = _buildFallback(iniciales);
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor != null && borderWidth > 0
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBackgroundColor,
        child: ClipOval(
          child: avatarChild,
        ),
      ),
    );
  }

  Widget _buildFallback(String iniciales) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      color: _getBackgroundColor(nombre),
      child: Text(
        iniciales,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getBackgroundColor(String name) {
    final colors = [
      const Color(0xFF4DC130),
      const Color(0xFF88D288),
      const Color(0xFF6BCA54),
      const Color(0xFF9BCE97),
      const Color(0xFFE8AB52),
      const Color(0xFFFA8E9E),
    ];
    return colors[name.length % colors.length];
  }
}
