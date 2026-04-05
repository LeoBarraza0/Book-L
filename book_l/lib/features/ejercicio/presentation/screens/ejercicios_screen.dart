import 'package:flutter/material.dart';

class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildAnimatedCard(
              title: "Teóricos",
              imageUrl:
                  'http://localhost:3845/assets/97d721d65cda6c381af1d405c8d26f13dcce76df.png',
              delay: 0,
            ),
            const SizedBox(height: 20),
            _buildAnimatedCard(
              title: "Prácticos",
              imageUrl:
                  'http://localhost:3845/assets/054aa59f66a0849c4fddffa77a03ace19440d588.png',
              delay: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(
      {required String title, required String imageUrl, required int delay}) {
    return _HoverScaleCard(
      title: title,
      imageUrl: imageUrl,
      delay: delay,
    );
  }
}

class _HoverScaleCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final int delay;

  const _HoverScaleCard({
    required this.title,
    required this.imageUrl,
    required this.delay,
  });

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> {
  bool _isPressed = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isVisible ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            // Mostrar un SnackBar de feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navegando a ejercicios ${widget.title.toLowerCase()}...')),
            );
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Imagen de fondo con Hero y BoxFit.cover
                  Positioned.fill(
                    child: Transform.scale(
                      scale: 1.15, // Ajuste para evitar que se corte el contenido útil del PNG
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.title == 'Teóricos'
                                  ? [const Color(0xFF6BCA54), const Color(0xFF389222)]
                                  : [const Color(0xFF5A5A5A), const Color(0xFF2C2C2C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradiente oscuro en la parte inferior para resaltar el texto
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Título
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Icono de flecha en el lateral derecho, centrado verticalmente
                  const Positioned(
                    top: 0,
                    bottom: 0,
                    right: 20,
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
