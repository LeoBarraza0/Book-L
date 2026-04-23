import 'package:flutter/material.dart';
import '../controller/discusion_controller.dart';
import '../widgets/comentario_tile.dart';
import '../../../calificacion/presentation/widgets/stars_rating_widget.dart';

class DiscusionScreen extends StatefulWidget {
  final bool showRating;
  final int? idLeccion;
  final int? idCurso;
  final DiscusionController? controller;
  final Future<void> Function(int)? onRatingChanged;

  const DiscusionScreen({
    super.key,
    this.showRating = false,
    this.idLeccion,
    this.idCurso,
    this.controller,
    this.onRatingChanged,
  });

  @override
  State<DiscusionScreen> createState() => _DiscusionScreenState();
}

class _DiscusionScreenState extends State<DiscusionScreen> {
  late final DiscusionController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? DiscusionController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.cargarDiscusion(
        idCurso: widget.idCurso,
        idLeccion: widget.idLeccion,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final state = _ctrl.state;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating opcional
            if (widget.showRating) ...[
              Center(
                child: StarsRatingWidget(
                  onRatingChanged: widget.onRatingChanged,
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Header con contador reactivo
            Row(
              children: [
                const Text(
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                if (!state.isLoading && state.discusion != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DC130).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.comentariosRaiz.length + state.respuestasPorPadre.values.fold<int>(0, (sum, l) => sum + l.length)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4DC130),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Estados de carga / vacío / contenido
            if (state.isLoading)
              _buildSkeleton()
            else if (state.discusion == null || state.comentariosRaiz.isEmpty)
              _buildEmptyState()
            else
              ...state.comentariosRaiz.map(
                (c) => ComentarioTile(
                  comentario: c,
                  respuestas: state.respuestasPorPadre[c.idComentario] ?? [],
                  ctrl: _ctrl,
                ),
              ),
            // Espacio para que el último comentario no quede tapado
            // por el ComentarioInput flotante (~80px) + NavBar (~90px)
            const SizedBox(height: 220),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF4DC130).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 36,
                color: Color(0xFF4DC130),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '¡Sé el primero en comentar!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Comparte tu opinión o haz una pregunta\nsobre este contenido.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black38, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

