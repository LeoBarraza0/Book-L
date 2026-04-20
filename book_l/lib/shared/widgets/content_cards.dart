import 'package:flutter/material.dart';
import '../../core/services/bookl_service.dart';
import '../../core/storage/local_storage.dart';
import '../../features/curso/domain/entities/curso.dart';
import '../../features/leccion/domain/entities/leccion.dart';

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
               offset: const Offset(0, 4)
             ),
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(iconData, color: iconColor, size: 40),
                  ),
                ),
                // Contenido de texto
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 12.0, bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        tagsArea,
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
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
      onTap: () => Navigator.pushNamed(context, '/leccion_detail', arguments: leccion.idLeccion),
      tagsArea: ListenableBuilder(
        listenable: BooklService(),
        builder: (context, _) {
          final authCursosIds = BooklService().leccionesCursos
              .where((lc) => lc['id_leccion'] == leccion.idLeccion)
              .map((lc) => lc['id_curso'])
              .toList();
          
          final tagNames = BooklService().cursos
              .where((c) => authCursosIds.contains(c.idCurso))
              .map((c) => c.nombre)
              .take(2)
              .toList();

          if (tagNames.isEmpty) {
            return _buildTag('Independiente', const Color(0xFF8BCA39));
          }

          return Row(
            children: tagNames.map((name) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildTag(name, const Color(0xFF8BCA39)),
            )).toList(),
          );
        },
      ),
      bottomArea: const Row(
        children: [
          Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 16),
          SizedBox(width: 2),
          Text('N/A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
        ],
      ),
      favoriteButton: _buildFavoriteButton(leccion.idLeccion, true),
      progressOverlay: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          fit: StackFit.expand,
          children: const [
            CircularProgressIndicator(
              value: 0.0,
              backgroundColor: Color(0x334DC130),
              color: Color(0xFF4DC130),
              strokeWidth: 4,
            ),
            Center(
              child: Text(
                '0%',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFavoriteButton(int id, bool isLeccion) {
    return ListenableBuilder(
      listenable: isLeccion ? AppSession().savedLecciones : AppSession().savedCursos,
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
      // Usamos el color rojo de marca pero con opacidad 0.2 para la caja
      iconBoxColor: const Color(0xFFFF606F).withValues(alpha: 0.2), 
      // y el rojo puro para el ícono directamente
      iconColor: const Color(0xFFFF606F), 
      iconData: Icons.school_rounded,
      onTap: () => Navigator.pushNamed(context, '/curso_detail', arguments: curso.idCurso),
      tagsArea: const SizedBox(), // Título queda arriba al hacer esto vacío
      bottomArea: const Text(
        'Toca para explorar el curso', 
        style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontWeight: FontWeight.w500)
      ),
      favoriteButton: ListenableBuilder(
        listenable: AppSession().savedCursos,
        builder: (context, _) {
          final isSaved = AppSession().savedCursos.value.contains(curso.idCurso);
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
    );
  }
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
  final VoidCallback onTap;

  const _BaseFypCard({
    required this.title,
    required this.tagsArea,
    this.newBadge,
    required this.imageBoxColor,
    required this.iconData,
    required this.iconColor,
    required this.favoriteButton,
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
                    border: Border.all(color: const Color(0xFF7CCC69).withValues(alpha: 0.3), width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Icon(iconData, color: iconColor, size: 80),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 20),
                      SizedBox(width: 4),
                      Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
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
      imageBoxColor: const Color(0xFF8BCA39).withValues(alpha: 0.2), // Verde suave para banner
      iconColor: const Color(0xFF4DC130), // Libro gigante translúcido
      iconData: Icons.menu_book_rounded,
      onTap: () => Navigator.pushNamed(context, '/leccion_detail', arguments: leccion.idLeccion),
      newBadge: _buildTag('Nuevo', const Color(0xFFF6B55C)), // Naranja
      tagsArea: ListenableBuilder(
        listenable: BooklService(),
        builder: (context, _) {
          final authCursosIds = BooklService().leccionesCursos
              .where((lc) => lc['id_leccion'] == leccion.idLeccion)
              .map((lc) => lc['id_curso'])
              .toList();
          
          final tagNames = BooklService().cursos
              .where((c) => authCursosIds.contains(c.idCurso))
              .map((c) => c.nombre)
              .take(1) // En FYP Figma solo muestra 1 tag
              .toList();

          if (tagNames.isEmpty) {
            return _buildTag('Independiente', const Color(0xFF4DC130)); // Verde oscuro
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
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFavoriteButton(int id, bool isLeccion) {
    return ListenableBuilder(
      listenable: isLeccion ? AppSession().savedLecciones : AppSession().savedCursos,
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
      imageBoxColor: const Color(0xFFFF606F).withValues(alpha: 0.15), // Rojo rosado suave
      iconColor: const Color(0xFFFF606F).withValues(alpha: 0.7), // Birrete gigante translúcido
      iconData: Icons.school_rounded,
      onTap: () => Navigator.pushNamed(context, '/curso_detail', arguments: curso.idCurso),
      newBadge: null, // Cursos en FYP no tienen badge Nuevo por ahora
      tagsArea: _buildTag('Curso', const Color(0xFFFF606F)), // Rojo marca
      favoriteButton: ListenableBuilder(
        listenable: AppSession().savedCursos,
        builder: (context, _) {
          final isSaved = AppSession().savedCursos.value.contains(curso.idCurso);
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
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
