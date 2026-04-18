import 'package:flutter/material.dart';
import 'package:book_l/shared/data/course_repository.dart';
import 'package:book_l/shared/domain/models/curso_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/create_menu_modal.dart' as lib_modal;
import 'mis_cursos_access_card.dart';
import 'course_list_tile.dart';
import 'course_grid_card.dart';

class MisCursosSection extends StatefulWidget {
  final VoidCallback onMisCursosTap;

  const MisCursosSection({
    super.key,
    required this.onMisCursosTap,
  });

  @override
  State<MisCursosSection> createState() => _MisCursosSectionState();
}

class _MisCursosSectionState extends State<MisCursosSection> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CursoModel>>(
      valueListenable: CourseRepository.instance.coursesNotifier,
      builder: (context, courses, _) {
        if (courses.isEmpty) {
          return _buildEmpty(context);
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isGridView 
            ? _buildGridView(context, courses) 
            : _buildOverview(context, courses),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          SvgPicture.asset(
            'assets/images/nocontent_icon.svg',
            width: 150, // Adjusted based on design
            height: 150,
          ),
          const SizedBox(height: 24),

          const Text(
            'Comparte conocimiento',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Cuando compartes algún dato, aparecerán en tu perfil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const lib_modal.CreateMenuModal();
                },
              );
            },
            child: const Text(
              'Sumate al desarrollo académico de la libre',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4DC130), // Main green
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4DC130),
              ),
            ),
          ),

          // Bottom padding to ensure the floating nav bar doesn't cover content
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ─── IMAGE 1: Overview ──────────────────────────────────────────────────

  Widget _buildOverview(BuildContext context, List<CursoModel> courses) {
    return SingleChildScrollView(
      key: const ValueKey('overview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(context),
          _buildSearchBar(context),
          const SizedBox(height: 8),
          ...courses.map((course) => CourseListTile(
            course: course,
            onTap: () {
              // Optionally handle tap
            },
          )),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ─── IMAGE 2: Grid View ─────────────────────────────────────────────────

  Widget _buildGridView(BuildContext context, List<CursoModel> courses) {
    return SingleChildScrollView(
      key: const ValueKey('grid'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search row with back button (Image 2 style)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _buildSearchBarBase(context, hasBack: true),
          ),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return CourseGridCard(course: courses[index]);
            },
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // ─── Widgets Compartidos ────────────────────────────────────────────────

  Widget _buildBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isGridView = true),
      child: Container(
        height: 130,
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD7FC61), // LIME
              Color(0xFF67B237), // BRAND GREEN
            ],
          ),
        ),
        child: Stack(
          children: [
            // Diagonal Striped Pattern
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPaint(
                  painter: DiagonalStripesPainter(),
                ),
              ),
            ),
            
            // Text "Mis cursos"
            const Positioned(
              bottom: 24,
              left: 20,
              child: Text(
                'Mis cursos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            // Red accent in top-right (Image 1)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 65,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFA8E9E), // SOFT PINK/RED
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildSearchBarBase(context),
    );
  }

  Widget _buildSearchBarBase(BuildContext context, {bool hasBack = false}) {
    return Row(
      children: [
        if (hasBack) ...[
          GestureDetector(
            onTap: () => setState(() => _isGridView = false),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF67B237), size: 24),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0), // Grey search bar as in Image 1
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Icon(Icons.close, color: Colors.black54, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFF82C46C), // Vibrant green button
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}

class DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.12) // Slightly darker stripes
      ..strokeWidth = 35
      ..strokeCap = StrokeCap.round;

    double x = -size.width;
    while (x < size.width * 2) {
      canvas.drawLine(
        Offset(x, -20),
        Offset(x + size.height * 0.8, size.height + 20),
        paint,
      );
      x += 80;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
