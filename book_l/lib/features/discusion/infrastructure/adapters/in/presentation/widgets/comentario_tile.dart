import 'package:flutter/material.dart';
import 'package:book_l/features/discusion/domain/models/comentario.dart';
import '../controller/discusion_controller.dart';
import 'package:book_l/shared/widgets/custom_avatar.dart';

class ComentarioTile extends StatefulWidget {
  final Comentario comentario;
  final List<Comentario> respuestas;
  final DiscusionController ctrl;

  const ComentarioTile({
    super.key,
    required this.comentario,
    required this.respuestas,
    required this.ctrl,
  });

  @override
  State<ComentarioTile> createState() => _ComentarioTileState();
}

class _ComentarioTileState extends State<ComentarioTile> {
  bool _expandRespuestas = false;

  String _tiempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = widget.ctrl.getUserSync(widget.comentario.idUsuarioFk);
    final nombre = usuario?.nombreCompleto ?? 'Usuario';
    final avatar = usuario?.avatarUrl as String?;
    final tiempo = _tiempoRelativo(widget.comentario.createdAt);
    final tieneRespuestas = widget.respuestas.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Comentario Principal ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar con borde verde
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF4DC130),
                  shape: BoxShape.circle,
                ),
                child: CustomAvatar(
                  radius: 18,
                  url: avatar,
                  nombre: nombre ?? 'Usuario',
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + tiempo
                    Row(
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          tiempo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Burbuja de comentario
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.comentario.contenido,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Acciones: Like + Responder + mostrar respuestas
                    Row(
                      children: [
                        // ── Botón Like ──
                        ListenableBuilder(
                          listenable: widget.ctrl,
                          builder: (context, _) {
                            final liked = widget.ctrl
                                .isLiked(widget.comentario.idComentario);
                            final count = widget.ctrl
                                .likeCount(widget.comentario.idComentario);
                            return GestureDetector(
                              onTap: () => widget.ctrl
                                  .toggleLike(widget.comentario.idComentario),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: liked
                                      ? const Color(0xFFFFEBEE)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      transitionBuilder: (child, anim) =>
                                          ScaleTransition(
                                              scale: anim, child: child),
                                      child: Icon(
                                        liked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        key: ValueKey(liked),
                                        size: 15,
                                        color: liked
                                            ? Colors.redAccent
                                            : Colors.black38,
                                      ),
                                    ),
                                    if (count > 0) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: liked
                                              ? Colors.redAccent
                                              : Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            widget.ctrl.setReplyTo(
                                widget.comentario.idComentario, nombre);
                          },
                          child: const Text(
                            'Responder',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4DC130),
                            ),
                          ),
                        ),
                        if (tieneRespuestas) ...[
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => setState(
                                () => _expandRespuestas = !_expandRespuestas),
                            child: Row(
                              children: [
                                Icon(
                                  _expandRespuestas
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 16,
                                  color: const Color(0xFF6BCA54),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _expandRespuestas
                                      ? 'Ocultar'
                                      : '${widget.respuestas.length} resp.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6BCA54),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Respuestas anidadas ───────────────────────────────────────
          if (tieneRespuestas && _expandRespuestas)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 10),
              child: Column(
                children: widget.respuestas
                    .map((r) => _RespuestaTile(respuesta: r, ctrl: widget.ctrl))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tile para respuestas anidadas (nivel 2) ──────────────────────────────────
class _RespuestaTile extends StatelessWidget {
  final Comentario respuesta;
  final DiscusionController ctrl;

  const _RespuestaTile({required this.respuesta, required this.ctrl});

  String _tiempoRelativo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ctrl.getUserSync(respuesta.idUsuarioFk);
    final nombre = usuario?.nombreCompleto ?? 'Usuario';
    final avatar = usuario?.avatarUrl as String?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea conectora vertical
          Container(
            width: 2,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4DC130).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          CustomAvatar(
            radius: 45,
            url: avatar,
            nombre: nombre,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black87)),
                    const Spacer(),
                    Text(
                      _tiempoRelativo(respuesta.createdAt),
                      style:
                          const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFF0),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                    border: Border.all(
                        color: const Color(0xFF4DC130).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    respuesta.contenido,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black87, height: 1.4),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => ctrl.setReplyTo(respuesta.idComentario, nombre),
                  child: const Text(
                    'Responder',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4DC130),
                    ),
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
