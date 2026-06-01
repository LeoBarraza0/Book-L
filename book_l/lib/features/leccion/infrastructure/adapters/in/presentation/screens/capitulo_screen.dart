import 'dart:io';
import 'package:flutter/material.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/shared/widgets/quill_read_only_view.dart';
import 'package:book_l/shared/widgets/video_player_widget.dart';
import 'package:book_l/shared/widgets/pdf_viewer_widget.dart';
import 'package:book_l/shared/widgets/header_background_image.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';

import '../controller/leccion_controller.dart';

import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/controller/ejercicios_controller.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/screens/teorico_screen.dart';

class CapituloScreen extends StatefulWidget {
  final int? idCapitulo;
  const CapituloScreen({super.key, this.idCapitulo});

  @override
  State<CapituloScreen> createState() => _CapituloScreenState();
}

class _CapituloScreenState extends State<CapituloScreen> {
  final _ctrl = LeccionController();

  @override
  void initState() {
    super.initState();
    _cargarData();
  }

  Future<void> _cargarData() async {
    if (widget.idCapitulo != null) {
      await _ctrl.seleccionarCapitulo(widget.idCapitulo!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: _ctrl,
                  builder: (context, _) => _buildHeaderImage(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Renderización dinámica del JSON `contenido`
                      ListenableBuilder(
                        listenable: _ctrl,
                        builder: (context, _) {
                          final cap = _ctrl.capituloSeleccionado;
                          if (cap != null &&
                              cap.contenido != null &&
                              cap.contenido!.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cap.nombre,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 16),
                                ...cap.contenido!.map((s) {
                                  final titulo = s['titulo'] as String? ?? '';
                                  final deltaData =
                                      s['cuerpo_delta'] as List<dynamic>?;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (titulo.isNotEmpty) ...[
                                          Text(
                                            titulo,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        QuillReadOnlyView(
                                          delta: deltaData,
                                          fontSize: 16,
                                          color: const Color(0xFF787878),
                                        ),
                                        if (s['tiene_imagen'] == true) ...[
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: (s['imagen_path'] != null &&
                                                    s['imagen_path']
                                                        .toString()
                                                        .isNotEmpty)
                                                ? (s['imagen_path'].toString().startsWith('http') ||
                                                        s['imagen_path']
                                                            .toString()
                                                            .startsWith(
                                                                'assets/'))
                                                    ? Image.network(
                                                        s['imagen_path'],
                                                        width: double.infinity,
                                                        height: 200,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) =>
                                                            _buildMediaItem(
                                                                Icons.image,
                                                                'Imagen adjunta',
                                                                const Color(
                                                                    0xFF4DC130)))
                                                    : Image.file(
                                                        File(s['imagen_path']),
                                                        width: double.infinity,
                                                        height: 200,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                _buildMediaItem(Icons.image, 'Imagen adjunta', const Color(0xFF4DC130)))
                                                : _buildMediaItem(Icons.image, 'Imagen adjunta', const Color(0xFF4DC130)),
                                          ),
                                        ],
                                        if (s['tiene_video'] == true) ...[
                                          const SizedBox(height: 12),
                                          if (s['video_path'] != null &&
                                              s['video_path']
                                                  .toString()
                                                  .isNotEmpty)
                                            VideoPlayerWidget(
                                                path:
                                                    s['video_path'].toString())
                                          else
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: _buildMediaItem(
                                                  Icons.play_circle_filled,
                                                  'Video adjunto',
                                                  const Color(0xFFFF606F)),
                                            ),
                                        ],
                                        if (s['tiene_pdf'] == true) ...[
                                          const SizedBox(height: 12),
                                          if (s['pdf_path'] != null &&
                                              s['pdf_path']
                                                  .toString()
                                                  .isNotEmpty)
                                            PdfViewerWidget(
                                              path: s['pdf_path'].toString(),
                                              nombre:
                                                  s['pdf_nombre'] as String?,
                                            )
                                          else
                                            _buildMediaItem(
                                                Icons.picture_as_pdf,
                                                'PDF adjunto',
                                                const Color(0xFF7B2FBE)),
                                        ],
                                      ],
                                    ),
                                  );
                                })
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Introducción',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Text(
                                  cap == null
                                      ? 'Cargando contenido...'
                                      : 'Aún no hay contenido para este capítulo.',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF787878),
                                      fontWeight: FontWeight.w600,
                                      height: 1.4),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 64),

                      // Sección de Pruebas
                      ListenableBuilder(
                          listenable: AppSession()
                              .completedEjercicios, // Escuchamos cambios en ejercicios completados
                          builder: (context, _) {
                            // Obtener ejercicios del capítulo vía controlador
                            final ejercicios = EjerciciosController()
                                .ejerciciosDeCapitulo(widget.idCapitulo!);

                            if (ejercicios.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: [
                                const Center(
                                  child: Text(
                                      '¡Pon a prueba tus conocimientos!',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 32),
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children:
                                      List.generate(ejercicios.length, (i) {
                                    final ex = ejercicios[i];
                                    return _buildPruebaButton(
                                        (i + 1).toString(), ex, context);
                                  }),
                                ),
                                const SizedBox(height: 48),
                              ],
                            );
                          }),

                      // Botón de completar capítulo
                      ListenableBuilder(
                        listenable: AppSession().completedCapitulos,
                        builder: (context, _) {
                          final isCompleted = AppSession()
                              .completedCapitulos
                              .value
                              .contains(widget.idCapitulo);
                          return Center(
                            child: GestureDetector(
                              onTap: () {
                                if (widget.idCapitulo != null) {
                                  AppSession().marcarCapituloCompletado(
                                      widget.idCapitulo!, !isCompleted);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFF4DC130)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: const Color(0xFF4DC130), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isCompleted
                                          ? const Color(0xFF4DC130)
                                              .withValues(alpha: 0.3)
                                          : Colors.black
                                              .withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCompleted
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isCompleted
                                          ? Colors.white
                                          : const Color(0xFF4DC130),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isCompleted
                                          ? 'Capítulo Completado'
                                          : 'Marcar como Completado',
                                      style: TextStyle(
                                        color: isCompleted
                                            ? Colors.white
                                            : const Color(0xFF4DC130),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar flotante
          const Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image (usa imagen de la lección padre o placeholder)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Builder(
                builder: (context) {
                  final cap = _ctrl.capituloSeleccionado;
                  String? imagenUrl;
                  if (cap != null) {
                    // Obtener imagen de la lección padre vía controlador
                    final leccion = _ctrl.state.items
                        .where((l) => l.idLeccion == cap.idLeccion)
                        .firstOrNull;
                    imagenUrl = leccion?.imagenUrl;
                  }
                  return HeaderBackgroundImage(
                    imagenUrl: imagenUrl,
                    fallbackAsset: 'assets/images/green_bg.png',
                    fallbackColor: const Color(0xFF4DC130),
                  );
                },
              ),
            ),
          ),
          // Botones Top (Nav)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularIconButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                  _buildCircularIconButton(Icons.share, () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF6BCA54).withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPruebaButton(String number, Ejercicio ex, BuildContext context) {
    Color getAccentColor() {
      switch (ex.tipo) {
        case TipoEjercicio.multipleChoice:
          return const Color(0xFF4DC130);
        case TipoEjercicio.trueFalse:
          return const Color(0xFFF6B55C);
        case TipoEjercicio.ordenar:
          return const Color(0xFF4DB0FF);
        case TipoEjercicio.rellenar:
          return const Color(0xFFFF606F);
        case TipoEjercicio.respuestaCorta:
          return const Color(0xFF9B51E0);
      }
    }

    final color = getAccentColor();
    final isCompleted =
        AppSession().completedEjercicios.value.contains(ex.idEjercicio);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeoricoScreen(ejercicio: ex),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 54)
                : Text(
                    number,
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            ex.tipo.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF565656),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(IconData icon, String label, Color color) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.7), size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
