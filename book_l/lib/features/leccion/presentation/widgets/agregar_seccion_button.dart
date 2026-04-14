import 'package:flutter/material.dart';

/// Botón circular punteado con ícono + que al pulsarse añade una nueva sección.
class AgregarSeccionButton extends StatefulWidget {
  final VoidCallback onTap;

  const AgregarSeccionButton({super.key, required this.onTap});

  @override
  State<AgregarSeccionButton> createState() => _AgregarSeccionButtonState();
}

class _AgregarSeccionButtonState extends State<AgregarSeccionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Center(
        child: Column(
          children: [
            // ── Círculo punteado pulsante ────────────────────────────────
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                widget.onTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isPressed ? 0.92 : _pulseAnim.value,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPressed
                        ? const Color(0xFF4DC130).withOpacity(0.10)
                        : Colors.white,
                    border: Border.all(
                      color: _isPressed
                          ? const Color(0xFF4DC130)
                          : const Color(0xFF7C7C7C),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DC130)
                            .withOpacity(_isPressed ? 0.30 : 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        Icons.add_rounded,
                        size: 38,
                        color: _isPressed
                            ? const Color(0xFF4DC130)
                            : const Color(0xFF6B6B6B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Etiqueta ────────────────────────────────────────────────
            Text(
              'Agregar sección',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.45),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
