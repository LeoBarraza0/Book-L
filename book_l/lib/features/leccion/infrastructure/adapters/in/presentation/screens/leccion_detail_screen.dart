import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/shared/widgets/reporte_modal.dart';
import 'package:book_l/shared/widgets/header_background_image.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/in/presentation/screens/discusion_screen.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/in/presentation/widgets/comentario_input.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/in/presentation/controller/discusion_controller.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/screens/ejercicios_screen.dart';
import 'package:book_l/features/guardado/infrastructure/adapters/in/presentation/controller/guardado_controller.dart';
import '../controller/leccion_controller.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/shared/widgets/quill_read_only_view.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';

import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/perfil/infrastructure/adapters/in/presentation/screens/perfil_screen.dart';
import 'package:book_l/shared/widgets/video_player_widget.dart';
import 'package:book_l/shared/widgets/pdf_viewer_widget.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/controller/calificacion_controller.dart';

enum CapituloStatus { completed, inProgress, locked }

class LeccionDetailScreen extends StatefulWidget {
  /// ID de la lección a mostrar. Si es null muestra datos placeholder.
  final int? idLeccion;

  const LeccionDetailScreen({super.key, this.idLeccion});

  @override
  State<LeccionDetailScreen> createState() => _LeccionDetailScreenState();
}

class _LeccionDetailScreenState extends State<LeccionDetailScreen> {
  int _selectedTab = 0; // 0: Contenido, 1: Ejercicios, 2: Discusión
  final LeccionController _ctrl = LeccionController();
  final DiscusionController _discCtrl = DiscusionController();

  @override
  void initState() {
    super.initState();
    if (widget.idLeccion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.seleccionarLeccion(widget.idLeccion!);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleRatingChanged(int valor) async {
    final leccionId = widget.idLeccion;
    if (leccionId == null) return;

    final result =
        await CalificacionController().calificarLeccion(leccionId, valor);

    if (result != null && mounted) {
      final isUpdate = result.$2;

      // Forzar actualización del controlador de lección local para refrescar el header
      _ctrl.seleccionarLeccion(leccionId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isUpdate
                      ? '¡Reseña actualizada con éxito!'
                      : '¡Gracias por compartir tu opinión!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4DC130),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB), // Color de fondo del layout
      body: Stack(
        children: [
          // ── Contenido Principal (Scroll) ─────────────────────────────
          CustomScrollView(
            slivers: [
              // 1. Imagen Superior (Header)
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: _ctrl,
                  builder: (context, _) => _buildHeaderImage(context),
                ),
              ),

              // 2. Cuerpo del detalle
              // 2. Cuerpo del detalle superior a los tabs
              SliverToBoxAdapter(
                child: ListenableBuilder(
                    listenable: _ctrl,
                    builder: (context, _) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndProgress(),
                            const SizedBox(height: 24),
                            _buildCursosAsociados(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      );
                    }),
              ),
              // 3. Tabs (Persistent Header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight:
                      80.0, // 42 (tab height) + 24 (bottom padding) + top padding
                  maxHeight: 80.0,
                  child: Container(
                    color: const Color(0xFFECEBEB),
                    padding: const EdgeInsets.only(
                        top: 14.0, bottom: 24.0, left: 20, right: 20),
                    child: _buildTabs(),
                  ),
                ),
              ),
              // 4. Cuerpo dinámico debajo de los tabs
              SliverToBoxAdapter(
                child: ListenableBuilder(
                    listenable: _ctrl,
                    builder: (context, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Render Dinámico según la Pestaña animado
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                    opacity: animation, child: child);
                              },
                              child: _selectedTab == 0
                                  ? Container(
                                      key: const ValueKey(0),
                                      child: _buildContenido())
                                  : _selectedTab == 1
                                      ? EjerciciosScreen(
                                          key: const ValueKey(1),
                                          idLeccion: widget.idLeccion ?? 0)
                                      : Container(
                                          key: const ValueKey(2),
                                          child: DiscusionScreen(
                                            key: const ValueKey(2),
                                            showRating: true,
                                            idLeccion: widget.idLeccion,
                                            controller: _discCtrl,
                                            onRatingChanged:
                                                _handleRatingChanged,
                                          ),
                                        ),
                            ),
                            const SizedBox(
                              height: 100,
                            ), // Espacio extra para el NavBar Flotante
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),

          // ── Input de Comentarios Flotante (Solo en pestaña Discusión) ──
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) => AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              bottom: _selectedTab == 2 ? 110 : -60,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _selectedTab == 2 ? 1.0 : 0.0,
                child: ComentarioInput(ctrl: _discCtrl),
              ),
            ),
          ),

          // ── Bottom Navigation Bar flotante ───────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // Componentes Privados
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 300, // Altura ajustada similar al diseño de Figma (298px)
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image (usa imagen subida o placeholder)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: HeaderBackgroundImage(
                imagenUrl: _ctrl.state.selected?.imagenUrl,
                fallbackAsset: 'assets/images/green_bg.png',
                fallbackColor: const Color(0xFF4DC130),
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
                  Row(
                    children: [
                      ListenableBuilder(
                        listenable: _ctrl,
                        builder: (context, _) {
                          final leccion = _ctrl.state.selected;
                          if (leccion != null &&
                              leccion.idUsuarioFk == AppSession().usuarioId) {
                            return Row(
                              children: [
                                _buildCircularIconButton(
                                  Icons.edit_rounded,
                                  () {
                                    Navigator.pushNamed(
                                        context, '/editar_leccion',
                                        arguments: leccion.idLeccion);
                                  },
                                ),
                                const SizedBox(width: 10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      ListenableBuilder(
                        listenable: GuardadoController(),
                        builder: (context, _) {
                          final isSaved = widget.idLeccion != null &&
                              GuardadoController()
                                  .isLeccionSaved(widget.idLeccion!);
                          return _buildCircularIconButton(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            () {
                              if (widget.idLeccion != null) {
                                GuardadoController()
                                    .toggleSavedLeccion(widget.idLeccion!);
                              }
                            },
                            color: isSaved
                                ? Colors.redAccent.withValues(alpha: 0.9)
                                : const Color(0xFF6BCA54)
                                    .withValues(alpha: 0.9),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildCircularIconButton(Icons.share, () {}),
                      // ── Botón Reportar (solo vista usuario, no dueño) ──
                      ListenableBuilder(
                        listenable: _ctrl,
                        builder: (context, _) {
                          final leccion = _ctrl.state.selected;
                          final isOwner = leccion != null &&
                              leccion.idUsuarioFk == AppSession().usuarioId;
                          if (isOwner || leccion == null)
                            return const SizedBox.shrink();
                          return Row(
                            children: [
                              const SizedBox(width: 10),
                              _buildCircularIconButton(
                                Icons.flag_rounded,
                                () async {
                                  final result = await ReporteModal.show(
                                    context,
                                    entidadTipo: 'Lección',
                                    entidadId: leccion.idLeccion,
                                    entidadNombre: leccion.nombre,
                                  );
                                  if (result == true && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.white),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                '¡Reporte enviado exitosamente!',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor:
                                            const Color(0xFF4DC130),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        margin: const EdgeInsets.all(20),
                                      ),
                                    );
                                  }
                                },
                                color: const Color(0xFFFF606F)
                                    .withValues(alpha: 0.9),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color ??
              const Color(0xFF6BCA54)
                  .withValues(alpha: 0.9), // Más visible sobre imagen
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTitleAndProgress() {
    final leccion = _ctrl.state.selected;
    final titulo = leccion?.nombre ?? 'Cargando...';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título + Info del Autor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // Información del creador vía controlador
              Builder(
                builder: (context) {
                  final creator = leccion != null
                      ? _ctrl.getCreadorSync(leccion.idUsuarioFk)
                      : null;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      _slideRoute(PerfilScreen(idUsuario: creator?.idUsuario)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xFF6BCA54),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          creator?.nombreCompleto ??
                              AppSession().nombreCompleto ??
                              'Autor de la lección',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF6BCA54),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFF79AC63),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            creator?.rol ?? 'Comunidad',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('|  ${leccion?.rating ?? 4.5}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: Color(0xFFF6B55C), size: 14),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Círculo de Progreso
        ListenableBuilder(
          listenable: AppSession().completedCapitulos,
          builder: (context, _) {
            final progress = leccion != null
                ? _ctrl.calcularProgresoLeccion(leccion.idLeccion)
                : 0.0;
            final percent = (progress * 100).toInt();

            return SizedBox(
              width: 65,
              height: 65,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 65,
                    height: 65,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFD9D9D9),
                      color: const Color(0xFF4DC130),
                      strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCursosAsociados() {
    final idLeccion = _ctrl.state.selected?.idLeccion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cursos asociados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) {
              // Cursos asociados vía controlador
              final asociados = _ctrl.getCursosAsociados(idLeccion ?? 0);

              if (asociados.isEmpty) {
                return const Text('Sin cursos asociados',
                    style: TextStyle(fontSize: 13, color: Colors.black45));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: asociados.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _buildCursoAsociadoItem(
                  context,
                  width: 130,
                  curso: asociados[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCursoAsociadoItem(BuildContext context,
      {required double width, required Curso curso}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/curso_detail', arguments: curso.idCurso);
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF81CF6E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          curso.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          _buildTabItem('Contenido', 0),
          _buildTabItem('Ejercicios', 1),
          _buildTabItem('Discusión', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4DC130) : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
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

  Widget _buildContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            final contenido = _ctrl.state.selected?.contenido;
            if (contenido == null || contenido.isEmpty) {
              return const Text(
                'Aún no hay introducción disponible para esta lección.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF787878),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contenido.map((s) {
                final titulo = s['titulo'] as String? ?? '';
                final deltaData = s['cuerpo_delta'] as List<dynamic>?;
                final bool tieneImagen = s['tiene_imagen'] == true;
                final bool tieneVideo = s['tiene_video'] == true;
                final String? imagenPath = s['imagen_path'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titulo.isNotEmpty) ...[
                        Text(
                          titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                      ],
                      QuillReadOnlyView(
                        delta: deltaData,
                        fontSize: 16,
                        color: const Color(0xFF787878),
                      ),
                      if (tieneImagen) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (imagenPath != null && imagenPath.isNotEmpty)
                              ? (imagenPath.startsWith('http') ||
                                      imagenPath.startsWith('assets/'))
                                  ? Image.network(imagenPath,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildMediaItem(
                                              Icons.image,
                                              'Imagen adjunta',
                                              const Color(0xFF4DC130)))
                                  : Image.file(File(imagenPath),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _buildMediaItem(
                                              Icons.image,
                                              'Imagen adjunta',
                                              const Color(0xFF4DC130)))
                              : _buildMediaItem(Icons.image, 'Imagen adjunta',
                                  const Color(0xFF4DC130)),
                        ),
                      ],
                      if (tieneVideo) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildCuerpoVideo(s['video_path']?.toString()),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 28),

        // ── Capítulos ──
        const Text('Capítulos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable:
              Listenable.merge([_ctrl, AppSession().completedCapitulos]),
          builder: (context, _) {
            final caps = _ctrl.capitulosDeLeccion;
            final completados = AppSession().completedCapitulos.value;

            if (caps.isEmpty) {
              return _buildCapitulosPlaceholder();
            }
            return Column(
              children: [
                for (int i = 0; i < caps.length; i++) ...[
                  _buildCapituloItem(
                    status: completados.contains(caps[i].idCapitulo)
                        ? CapituloStatus.completed
                        : CapituloStatus
                            .inProgress, // Podríamos añadir lógica de 'locked' si se desea secuencialidad
                    title: caps[i].nombre,
                    duration: _formatDuracion(caps[i].tiempoTotal),
                    number: i + 1,
                    capitulo: caps[i],
                  ),
                  if (i < caps.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // ── Material Relacionado ──
        const Text('Material Relacionado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            // Materiales educativos vía controlador
            final leccionId = _ctrl.state.selected?.idLeccion;
            final materiales =
                leccionId != null ? _ctrl.materialesDeLeccion(leccionId) : [];

            if (materiales.isEmpty) {
              return const Text('No hay material adicional disponible.',
                  style: TextStyle(fontSize: 14, color: Colors.grey));
            }

            return Column(
              children: materiales
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMaterialItem(
                          icon: m.tipo == 'documento' || m.tipo == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.play_circle_filled,
                          title: m.nombre,
                          duration: m.tamanoBytes > 0
                              ? '${(m.tamanoBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
                              : 'Enlace',
                          iconColor: m.tipo == 'video'
                              ? const Color(0xFFFF606F)
                              : const Color(0xFF4DC130),
                          onTap: () async {
                            if (m.url == null || m.url!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Este material no tiene un archivo o enlace válido.')),
                              );
                              return;
                            }

                            bool isWebUrl = m.url!.startsWith('http');
                            bool isYouTube = isWebUrl &&
                                (m.url!.contains('youtube.com') ||
                                    m.url!.contains('youtu.be'));

                            if (m.tipo == 'video') {
                              if (isYouTube) {
                                try {
                                  await launchUrl(Uri.parse(m.url!),
                                      mode: LaunchMode.externalApplication);
                                } catch (_) {}
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                            appBar: AppBar(
                                                title: Text(m.nombre),
                                                elevation: 0),
                                            backgroundColor: Colors.black,
                                            body: Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: VideoPlayerWidget(
                                                  path: m.url!),
                                            )),
                                          )));
                            } else if (m.tipo == 'pdf' ||
                                m.tipo == 'documento') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                            appBar: AppBar(
                                                title: Text(m.nombre),
                                                elevation: 0),
                                            body: PdfViewerWidget(path: m.url!),
                                          )));
                            } else if (m.tipo == 'enlace') {
                              try {
                                await launchUrl(Uri.parse(m.url!),
                                    mode: LaunchMode.externalApplication);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'No se pudo abrir el enlace: ${m.url}')),
                                );
                              }
                            }
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 32),

        // ── Autor ──
        const Text('Autor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _buildAutorCard(),
      ],
    );
  }

  Widget _buildCuerpoVideo(String? path) {
    if (path == null || path.isEmpty) {
      return _buildMediaItem(Icons.play_circle_filled,
          'Falta la ruta del video', const Color(0xFFFF606F));
    }

    final isWebUrl = path.startsWith('http');
    final isYouTube =
        isWebUrl && (path.contains('youtube.com') || path.contains('youtu.be'));

    if (isYouTube) {
      return GestureDetector(
        onTap: () async {
          try {
            await launchUrl(Uri.parse(path),
                mode: LaunchMode.externalApplication);
          } catch (_) {}
        },
        child: _buildMediaItem(
            Icons.ondemand_video, 'Ver en YouTube', const Color(0xFFFF0000)),
      );
    }

    return VideoPlayerWidget(path: path);
  }

  // Convierte segundos a texto legible (ej: 900 → "15 min")
  String _formatDuracion(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final mins = segundos ~/ 60;
    if (mins < 60) return '$mins min';
    final horas = mins ~/ 60;
    final resto = mins % 60;
    return resto == 0 ? '${horas}h' : '${horas}h ${resto}min';
  }

  // Placeholder cuando la lección aún no se ha cargado
  Widget _buildCapitulosPlaceholder() {
    return Column(
      children: List.generate(
          3,
          (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )),
    );
  }

  Widget _buildCapituloItem({
    required CapituloStatus status,
    required String title,
    required String duration,
    int? number,
    Capitulo? capitulo,
  }) {
    bool isLocked = status == CapituloStatus.locked;
    bool isInProgress = status == CapituloStatus.inProgress;
    bool isCompleted = status == CapituloStatus.completed;

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Navigator.pushNamed(context, '/capitulo_detail',
              arguments: capitulo?.idCapitulo);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
          border: isInProgress
              ? Border.all(color: const Color(0xFF4DC130), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icono Redondo o Número
            if (isCompleted)
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: Color(0xFF4DC130), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 28),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked
                      ? const Color(0xFFAFAFAF)
                      : const Color(0xFFBDBDBD),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number?.toString() ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(duration,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF676767),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Etiqueta "En curso" si aplica
            if (isInProgress)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF4DC130).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('En curso',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem({
    required IconData icon,
    required String title,
    required String duration,
    Color iconColor = const Color(0xFF4DC130),
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(color: iconColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(duration,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF676767),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_outlined,
                size: 20, color: Color(0xFF787878)),
          ],
        ),
      ),
    );
  }

  Widget _buildAutorCard() {
    final leccion = _ctrl.state.selected;
    return Builder(
      builder: (context) {
        // Info del creador vía controlador
        final creator =
            leccion != null ? _ctrl.getCreadorSync(leccion.idUsuarioFk) : null;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            _slideRoute(PerfilScreen(idUsuario: creator?.idUsuario)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 75,
                    height: 75,
                    color: const Color(0xFF6BCA54),
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator?.nombreCompleto ??
                            AppSession().nombreCompleto ??
                            'Autor de la lección',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${creator?.rol ?? "Profesor"} de ${creator?.programa ?? "Ingeniería"}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black26),
              ],
            ),
          ),
        );
      },
    );
  }

  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
