import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/domain/models/curso_model.dart';

class CourseListTile extends StatelessWidget {
  final CursoModel course;
  final VoidCallback? onTap;

  const CourseListTile({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String categoryLabel =
        course.tags.isNotEmpty ? course.tags.first : 'General';
    final String badgeLabel = course.esNuevo
        ? 'Nuevo'
        : (course.tags.length > 1 ? course.tags[1] : 'Destacado');
    final Color badgeColor =
        course.esNuevo ? const Color(0xFFF6B55C) : const Color(0xFFFF606F);

    // Placeholder image since CursoModel doesn't have an imageUrl yet
    final String imageUrl =
        'http://localhost:3845/assets/8c82a4b652fc817b4e269031a428e684d5d7d999.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor de Imagen con Labels
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFD9D9D9), // Placeholder color
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.05),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Categoría (Top Left)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DC130),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Badge (Top Right)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Icono Favorito (Bottom Right)
                  const Positioned(
                    bottom: 12,
                    right: 12,
                    child: Icon(
                      Icons.favorite_border,
                      color: Color(0xFFFF606F),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Título y Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF6B55C), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
