import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget reutilizable para reproducir un video local o desde URL.
class VideoPlayerWidget extends StatefulWidget {
  final String path;

  const VideoPlayerWidget({super.key, required this.path});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      if (widget.path.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.path.trim()),
        );
      } else {
        String filePath = widget.path.trim();
        if (filePath.startsWith('file://')) {
          filePath = Uri.parse(filePath).toFilePath();
        }
        _controller = VideoPlayerController.file(File(filePath));
      }
      await _controller.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e, stack) {
      debugPrint('Error inicializando video: \$e');
      debugPrint(stack.toString());
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildPlaceholder('No se pudo cargar el video');
    }
    if (!_initialized) {
      return _buildPlaceholder(null);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Colors.black, // Fondo oscuro (letterbox) para videos de otros formatos
          child: Stack(
            alignment: Alignment.center,
            children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio > 0 ? _controller.value.aspectRatio : 16/9,
            child: VideoPlayer(_controller),
          ),
          // Overlay oscuro cuando está pausado
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (_, value, __) {
              return AnimatedOpacity(
                opacity: value.isPlaying ? 0.0 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black),
              );
            },
          ),
          // Botón play/pause central
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _controller,
            builder: (_, value, __) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    value.isPlaying ? _controller.pause() : _controller.play();
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: const Color(0xFF4DC130),
                    size: 34,
                  ),
                ),
              );
            },
          ),
          // Barra de progreso inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller,
              builder: (_, value, __) {
                final duration = value.duration.inMilliseconds.toDouble();
                final pos = value.position.inMilliseconds.toDouble();
                return Column(
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF4DC130),
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.black26,
                      ),
                    ),
                    Container(
                      color: Colors.black45,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String? message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (message == null) ...[
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF606F)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Cargando video...',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ] else ...[
              const Icon(Icons.error_outline, color: Color(0xFFFF606F), size: 36),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
