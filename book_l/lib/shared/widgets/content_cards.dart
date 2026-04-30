import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/bookl_service.dart';
import '../../core/storage/local_storage.dart';
import '../../features/curso/domain/entities/curso.dart';
import '../../features/curso/presentation/controller/curso_controller.dart';
import '../../features/leccion/domain/entities/leccion.dart';
import '../../features/leccion/presentation/controller/leccion_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Card Base que estandariza diseño, tamaño de cajitas y estructura visual.
// ─────────────────────────────────────────────────────────────────────────────
class _BaseContentCard extends StatelessWidget {
  final String title;
  final Widget tagsArea;
  final Widget bottomArea;
  final Color iconBoxColor;
  final IconData iconData;
  final Color iconColor;
  final Widget favoriteButton;
  final Widget? progressOverlay;
  final String? imageUrl;
  final VoidCallback onTap;

  const _BaseContentCard({
    required this.title,
    required this.tagsArea,
    required this.bottomArea,
    required this.iconBoxColor,
    required this.iconData,
    required this.iconColor,
    required this.favoriteButton,
    this.progressOverlay,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Cajita de imagen (Estandarizada)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: iconBoxColor,
                      borderRadius: BorderRadius.circular(16),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: _resolveImageProvider(imageUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: imageUrl == null
                        ? Icon(iconData, color: iconColor, size: 40)
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(width: 14),
                // Contenido de texto
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 12.0, top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tagsArea,
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (bottomArea is! SizedBox) ...[
                          const Spacer(),
                          bottomArea,
                        ]
                      ],
                    ),
                  ),
                ),
                // Espacio extra para overlays si hay items a la derecha
                const SizedBox(width: 48),
              ],
            ),

            // Botón de Favorito Estandarizado (Arriba Derecha)
            Positioned(
              top: 12,
              right: 16,
              child: favoriteButton,
            ),

            // Posible overlay de progreso (Abajo Derecha)
            if (progressOverlay != null)
              Positioned(
                bottom: 12,
                right: 16,
                child: progressOverlay!,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta Específica de Lección
// ─────────────────────────────────────────────────────────────────────────────
class SharedLeccionCard extends StatelessWidget {
  final Leccion leccion;

  const SharedLeccionCard({super.key, required this.leccion});

  @override
  Widget build(BuildContext context) {
    return _BaseContentCard(
      title: leccion.nombre,
      iconBoxColor: const Color(0xFF4DC130),
      iconColor: Colors.white,
      iconData: Icons.menu_book_rounded,
      imageUrl: leccion.imagenUrl ?? _extractImageUrl(leccion.contenido),
      onTap: () => Navigator.pushNamed(context, '/leccion_detail',
          arguments: leccion.idLeccion),
      tagsArea: ListenableBuilder(
        listenable: BooklService(),
        builder: (context, _) {
          final authCursosIds = BooklService()
              .leccionesCursos
              .where((lc) => lc['id_leccion'] == leccion.idLeccion)
              .map((lc) => lc['id_curso'])
              .toList();

          final tagNames = BooklService()
              .cursos
              .where((c) => authCursosIds.contains(c.idCurso))
              .map((c) => c.nombre)
              .take(2)
              .toList();

          if (tagNames.isEmpty) {
            return _buildTag('Independiente', const Color(0xFF8BCA39));
          }

          return Row(
            children: tagNames
                .map((name) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _buildTag(name, const Color(0xFF8BCA39)),
                    ))
                .toList(),
          );
        },
      ),
      bottomArea: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
          const SizedBox(width: 2),
          Text(
            leccion.rating > 0 ? leccion.rating.toStringAsFixed(1) : '4.5',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87),
          ),
        ],
      ),
      favoriteButton: _buildFavoriteButton(leccion.idLeccion, true),
      progressOverlay: ListenableBuilder(
        listenable: AppSession().completedCapitulos,
        builder: (context, _) {
          final progress = LeccionController().calcularProgresoLeccion(leccion.idLeccion);
          final percent = (progress * 100).toInt();
          return SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0x334DC130),
                  color: const Color(0xFF4DC130),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '$percent%',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(maxWidth: 80),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFavoriteButton(int id, bool isLeccion) {
    return ListenableBuilder(
      listenable:
          isLeccion ? AppSession().savedLecciones : AppSession().savedCursos,
      builder: (context, _) {
        final isSaved = isLeccion
            ? AppSession().savedLecciones.value.contains(id)
            : AppSession().savedCursos.value.contains(id);

        return GestureDetector(
          onTap: () {
            if (isLeccion) {
              AppSession().toggleSavedLeccion(id);
            } else {
              AppSession().toggleSavedCurso(id);
            }
          },
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
            size: 24,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta Específica de Curso
// ─────────────────────────────────────────────────────────────────────────────
class SharedCursoCard extends StatelessWidget {
  final Curso curso;

  const SharedCursoCard({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    return _BaseContentCard(
      title: curso.nombre,
      iconBoxColor: const Color(0xFFFF606F).withValues(alpha: 0.2),
      iconColor: const Color(0xFFFF606F),
      iconData: Icons.school_rounded,
      imageUrl: curso.imagenUrl ?? _extractImageUrl(curso.contenido),
      onTap: () => Navigator.pushNamed(context, '/curso_detail',
          arguments: curso.idCurso),
      tagsArea: const SizedBox(), // Título queda arriba al hacer esto vacío
      bottomArea: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
          const SizedBox(width: 4),
          Text(
            curso.rating > 0 ? curso.rating.toStringAsFixed(1) : '4.5',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87),
          ),
          const SizedBox(width: 8),
          const Text('•',
              style: TextStyle(fontSize: 12, color: Colors.black26)),
          const SizedBox(width: 8),
          const Text('Toca para explorar',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
        ],
      ),
      favoriteButton: ListenableBuilder(
        listenable: AppSession().savedCursos,
        builder: (context, _) {
          final isSaved =
              AppSession().savedCursos.value.contains(curso.idCurso);
          return GestureDetector(
            onTap: () {
              AppSession().toggleSavedCurso(curso.idCurso);
            },
            child: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
              size: 24,
            ),
          );
        },
      ),
      progressOverlay: ListenableBuilder(
        listenable: AppSession().completedCapitulos,
        builder: (context, _) {
          final progress =
              CursoController().calcularProgresoCurso(curso.idCurso);
          final percent = (progress * 100).toInt();
          return SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0x33FF606F),
                  color: const Color(0xFFFF606F),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String? _extractImageUrl(List<dynamic>? contenido) {
  if (contenido == null || contenido.isEmpty) return null;
  final first = contenido.first;
  if (first is Map && first['tiene_imagen'] == true) {
    return first['imagen_url']?.toString();
  }
  return null;
}

/// Resuelve un ImageProvider según el tipo de path (red, asset o archivo local).
ImageProvider _resolveImageProvider(String url) {
  if (url.startsWith('http')) return NetworkImage(url);
  if (url.startsWith('assets/')) return AssetImage(url);
  if (!kIsWeb) return FileImage(File(url));
  return NetworkImage(url); // fallback
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjetas Verticales Grandes para el FYP (Feed Principal)
// ─────────────────────────────────────────────────────────────────────────────

class _BaseFypCard extends StatelessWidget {
  final String title;
  final Widget tagsArea;
  final Widget? newBadge;
  final Color imageBoxColor;
  final IconData iconData;
  final Color iconColor;
  final Widget favoriteButton;
  final String durationStr;
  final double rating;
  final String? imageUrl;
  final VoidCallback onTap;

  const _BaseFypCard({
    required this.title,
    required this.tagsArea,
    this.newBadge,
    required this.imageBoxColor,
    required this.iconData,
    required this.iconColor,
    required this.favoriteButton,
    required this.durationStr,
    required this.rating,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Gigante
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 210,
                  decoration: BoxDecoration(
                    color: imageBoxColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF7CCC69).withValues(alpha: 0.3),
                        width: 1),
                    image: imageUrl != null
                        ? DecorationImage(
                            image: _resolveImageProvider(imageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: imageUrl == null
                      ? Icon(iconData, color: iconColor, size: 80)
                      : const SizedBox(),
                ),
                // Gradiente encima de la imagen si hay para que se lean las etiquetas y el corazón
                if (imageUrl != null)
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4), // Para top tags
                          Colors.transparent,
                          Colors.black
                              .withValues(alpha: 0.4), // Para bottom icons
                        ],
                      ),
                    ),
                  ),
                // Etiquetas top-left
                Positioned(
                  top: 12,
                  left: 12,
                  child: tagsArea,
                ),
                // Badge "Nuevo" top-right
                if (newBadge != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: newBadge!,
                  ),
                // Corazón bottom-right
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: favoriteButton,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Rodapié (Título y Puntuación)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating > 0 ? rating.toStringAsFixed(1) : '4.5',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FypLeccionCard extends StatelessWidget {
  final Leccion leccion;

  const FypLeccionCard({super.key, required this.leccion});

  @override
  Widget build(BuildContext context) {
    return _BaseFypCard(
      title: leccion.nombre,
      imageBoxColor: const Color(0xFF8BCA39)
          .withValues(alpha: 0.2), // Verde suave para banner
      iconColor: const Color(0xFF4DC130), // Libro gigante translúcido
      iconData: Icons.menu_book_rounded,
      imageUrl: leccion.imagenUrl ?? _extractImageUrl(leccion.contenido),
      durationStr: '3H 2M',
      rating: leccion.rating,
      onTap: () => Navigator.pushNamed(context, '/leccion_detail',
          arguments: leccion.idLeccion),
      newBadge: _buildTag('Nuevo', const Color(0xFFF6B55C)), // Naranja
      tagsArea: ListenableBuilder(
        listenable: BooklService(),
        builder: (context, _) {
          final authCursosIds = BooklService()
              .leccionesCursos
              .where((lc) => lc['id_leccion'] == leccion.idLeccion)
              .map((lc) => lc['id_curso'])
              .toList();

          final tagNames = BooklService()
              .cursos
              .where((c) => authCursosIds.contains(c.idCurso))
              .map((c) => c.nombre)
              .take(1) // En FYP Figma solo muestra 1 tag
              .toList();

          if (tagNames.isEmpty) {
            return _buildTag(
                'Independiente', const Color(0xFF4DC130)); // Verde oscuro
          }

          return _buildTag(tagNames.first, const Color(0xFF4DC130));
        },
      ),
      favoriteButton: _buildFavoriteButton(leccion.idLeccion, true),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFavoriteButton(int id, bool isLeccion) {
    return ListenableBuilder(
      listenable:
          isLeccion ? AppSession().savedLecciones : AppSession().savedCursos,
      builder: (context, _) {
        final isSaved = isLeccion
            ? AppSession().savedLecciones.value.contains(id)
            : AppSession().savedCursos.value.contains(id);

        return GestureDetector(
          onTap: () {
            if (isLeccion) {
              AppSession().toggleSavedLeccion(id);
            } else {
              AppSession().toggleSavedCurso(id);
            }
          },
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
            size: 30, // Un poco más grande como en Figma
          ),
        );
      },
    );
  }
}

class FypCursoCard extends StatelessWidget {
  final Curso curso;

  const FypCursoCard({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    return _BaseFypCard(
      title: curso.nombre,
      imageBoxColor:
          const Color(0xFFFF606F).withValues(alpha: 0.15), // Rojo rosado suave
      iconColor: const Color(0xFFFF606F)
          .withValues(alpha: 0.7), // Birrete gigante translúcido
      iconData: Icons.school_rounded,
      imageUrl: curso.imagenUrl ?? _extractImageUrl(curso.contenido),
      durationStr: '8H 15M',
      rating: curso.rating,
      onTap: () => Navigator.pushNamed(context, '/curso_detail',
          arguments: curso.idCurso),
      newBadge: null, // Cursos en FYP no tienen badge Nuevo por ahora
      tagsArea: _buildTag('Curso', const Color(0xFFFF606F)), // Rojo marca
      favoriteButton: ListenableBuilder(
        listenable: AppSession().savedCursos,
        builder: (context, _) {
          final isSaved =
              AppSession().savedCursos.value.contains(curso.idCurso);
          return GestureDetector(
            onTap: () {
              AppSession().toggleSavedCurso(curso.idCurso);
            },
            child: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
              size: 30,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
