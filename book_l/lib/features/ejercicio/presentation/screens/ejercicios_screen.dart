import 'package:flutter/material.dart';
import '../../domain/entities/ejercicio.dart';
import '../controller/ejercicios_controller.dart';
import 'banco_ejercicios_screen.dart';

/// Pestaña "Ejercicios" dentro de leccion_detail_screen.
/// Muestra una card por cada tipo de ejercicio que exista en los capítulos
/// de la lección. Si aparecen nuevos tipos, se generan automáticamente.
class EjerciciosScreen extends StatefulWidget {
  final int idLeccion;
  const EjerciciosScreen({super.key, required this.idLeccion});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen>
    with SingleTickerProviderStateMixin {
  final EjerciciosController _ctrl = EjerciciosController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // Configuración visual por tipo
  static const _tipoConfig = <TipoEjercicio, _TipoVisual>{
    TipoEjercicio.multipleChoice: _TipoVisual(
      icon: Icons.quiz_outlined,
      color: Color(0xFF4DC130),
      bgAsset: 'assets/images/green_bg.png',
      gradientColors: [Color(0xFF6BCA54), Color(0xFF389222)],
    ),
    TipoEjercicio.trueFalse: _TipoVisual(
      icon: Icons.check_circle_outline,
      color: Color(0xFFF6B55C),
      bgAsset: 'assets/images/yellow_bg.png',
      gradientColors: [Color(0xFFF6B55C), Color(0xFFE09830)],
    ),
    TipoEjercicio.ordenar: _TipoVisual(
      icon: Icons.swap_vert_rounded,
      color: Color(0xFF4DB0FF),
      bgAsset: null,
      gradientColors: [Color(0xFF4DB0FF), Color(0xFF2B7FD4)],
    ),
    TipoEjercicio.rellenar: _TipoVisual(
      icon: Icons.text_fields_rounded,
      color: Color(0xFFFF606F),
      bgAsset: null,
      gradientColors: [Color(0xFFFF606F), Color(0xFFD43A48)],
    ),
    TipoEjercicio.respuestaCorta: _TipoVisual(
      icon: Icons.short_text_rounded,
      color: Color(0xFF9B51E0),
      bgAsset: null,
      gradientColors: [Color(0xFF9B51E0), Color(0xFF7B3BB8)],
    ),
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final categorias = <String>[];
        if (_ctrl.tieneCategoria(widget.idLeccion, 'Teórico')) categorias.add('Teórico');
        if (_ctrl.tieneCategoria(widget.idLeccion, 'Práctico')) categorias.add('Práctico');

        if (categorias.isEmpty) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: _buildEmptyState(),
          );
        }

        return FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: List.generate(categorias.length, (i) {
                final cat = categorias[i];
                final count = _ctrl.getCountByCategoria(widget.idLeccion, cat);
                final visual = cat == 'Teórico'
                    ? _tipoConfig[TipoEjercicio.multipleChoice]!
                    : _tipoConfig[TipoEjercicio.ordenar]!;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EjercicioTipoCard(
                    titulo: 'Ejercicios ${cat}s',
                    visual: visual,
                    count: count,
                    delay: i * 120,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BancoEjerciciosScreen(
                            idLeccion: widget.idLeccion,
                            title: 'Ejercicios ${cat}s',
                            categoriaFiltro: cat,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4DC130).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_outlined, size: 36, color: Color(0xFF4DC130)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin ejercicios disponibles',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los ejercicios se agregan desde la edición de capítulos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 13, color: Colors.black38, height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoVisual {
  final IconData icon;
  final Color color;
  final String? bgAsset;
  final List<Color> gradientColors;

  const _TipoVisual({
    required this.icon,
    required this.color,
    this.bgAsset,
    required this.gradientColors,
  });
}

class _EjercicioTipoCard extends StatefulWidget {
  final String titulo;
  final _TipoVisual visual;
  final int count;
  final int delay;
  final VoidCallback onTap;

  const _EjercicioTipoCard({
    required this.titulo,
    required this.visual,
    required this.count,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_EjercicioTipoCard> createState() => _EjercicioTipoCardState();
}

class _EjercicioTipoCardState extends State<_EjercicioTipoCard> {
  bool _isPressed = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _isVisible = true);
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
        transform: Matrix4.identity()..scaleByDouble(_isPressed ? 0.96 : 1.0, _isPressed ? 0.96 : 1.0, 1.0, 1.0),
        transformAlignment: Alignment.center,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: widget.visual.bgAsset != null
                        ? Transform.scale(
                            scale: 1.15,
                            child: Image.asset(
                              widget.visual.bgAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildGradientBg(),
                            ),
                          )
                        : _buildGradientBg(),
                  ),
                  // Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(widget.visual.icon, color: Colors.white70, size: 18),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${widget.count} ejercicio${widget.count != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter', fontSize: 11,
                                        fontWeight: FontWeight.w600, color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                                Text(
                                  widget.titulo,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                      ],
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

  Widget _buildGradientBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.visual.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
