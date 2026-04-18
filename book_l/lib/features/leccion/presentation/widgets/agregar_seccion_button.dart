import 'package:flutter/material.dart';

/// Botón circular con ícono + que al pulsarse añade un nuevo elemento.
class AgregarSeccionButton extends StatefulWidget {
  final VoidCallback onTap;
  final String titulo;

  const AgregarSeccionButton({
    super.key, 
    required this.onTap,
    this.titulo = 'Agregar sección',
  });

  @override
  State<AgregarSeccionButton> createState() => _AgregarSeccionButtonState();
}

class _AgregarSeccionButtonState extends State<AgregarSeccionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Column(
          children: [
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPressed
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: _isPressed
                        ? const Color(0xFF565656)
                        : const Color(0xFF676767),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.add_rounded,
                      size: 40,
                      color: _isPressed
                          ? const Color(0xFF404040)
                          : const Color(0xFF676767),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.titulo,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF565656),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
