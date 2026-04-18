import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/data/course_repository.dart';
import 'package:book_l/shared/domain/models/curso_model.dart';

/// Grid view of created courses – matches Image 2.
/// Large cards with green gradient background, category tags, "Nuevo" badge, rating.
class MisCursosScreen extends StatelessWidget {
  const MisCursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF88D288),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Mis cursos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<CursoModel>>(
        valueListenable: CourseRepository.instance.coursesNotifier,
        builder: (context, courses, _) {
          if (courses.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildGrid(context, courses);
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 72, color: Colors.black26),
          SizedBox(height: 20),
          Text(
            'Aún no tienes cursos publicados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Crea tu primer curso desde el perfil',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, List<CursoModel> courses) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _CourseGridCard(course: courses[index]);
      },
    );
  }
}

/// Card matching Image 2: green gradient BG, tags, "Nuevo" badge, rating, heart.
class _CourseGridCard extends StatelessWidget {
  final CursoModel course;

  const _CourseGridCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/green_bg.svg',
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlay (bottom-heavy for readability)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Heart button (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 16,
                  color: Color(0xFFE57373),
                ),
              ),
            ),

            // Top tags row
            Positioned(
              top: 10,
              left: 10,
              right: 40,
              child: Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  if (course.tags.isNotEmpty)
                    _Tag(
                      label: course.tags.first,
                      color: const Color(0xFF3D6AFF),
                    ),
                  if (course.esNuevo)
                    _Tag(
                      label: 'Nuevo',
                      color: const Color(0xFFFF8C42),
                    ),
                ],
              ),
            ),

            // Bottom content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          course.rating > 0
                              ? course.rating.toStringAsFixed(1)
                              : '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
