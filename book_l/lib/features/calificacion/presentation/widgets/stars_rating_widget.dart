import 'package:flutter/material.dart';

class StarsRatingWidget extends StatefulWidget {
  final Future<void> Function(int)? onRatingChanged;
  final bool showTitle;
  final bool showSendButton;
  final double starSize;

  const StarsRatingWidget({
    super.key,
    this.onRatingChanged,
    this.showTitle = true,
    this.showSendButton = true,
    this.starSize = 42,
  });

  @override
  State<StarsRatingWidget> createState() => _StarsRatingWidgetState();
}

class _StarsRatingWidgetState extends State<StarsRatingWidget> {
  int _currentRating = 0;
  bool _isLoading = false;

  Future<void> _handleSend() async {
    if (_currentRating == 0 || _isLoading) return;

    setState(() => _isLoading = true);
    
    if (widget.onRatingChanged != null) {
      await widget.onRatingChanged!(_currentRating);
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleStarTap(int index) {
    if (_isLoading) return;
    setState(() {
      _currentRating = index + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showTitle) ...[
          const Text(
            'Tu calificación',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final isSelected = index < _currentRating;
            
            return _StarItem(
              isSelected: isSelected,
              onTap: () => _handleStarTap(index),
              starSize: widget.starSize,
            );
          }),
        ),
        const SizedBox(height: 12),
        // Botón de enviar con transición de entrada
        if (widget.showSendButton)
          AnimatedOpacity(
            opacity: _currentRating > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Visibility(
              visible: _currentRating > 0,
              child: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4DC130)),
                    ),
                  )
                : TextButton(
                    onPressed: _handleSend,
                    child: const Text(
                      '¡Enviar reseña!',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        color: Color(0xFF4DC130),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
            ),
          ),
      ],
    );
  }
}

class _StarItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final double starSize;

  const _StarItem({required this.isSelected, required this.onTap, required this.starSize});

  @override
  State<_StarItem> createState() => _StarItemState();
}

class _StarItemState extends State<_StarItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_StarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque, // Asegura que el toque se registre bien
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            widget.isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
            color: widget.isSelected ? const Color(0xFFF6B55C) : const Color(0xFFD9D9D9),
            size: widget.starSize,
          ),
        ),
      ),
    );
  }
}
