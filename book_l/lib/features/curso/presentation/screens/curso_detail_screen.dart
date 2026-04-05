import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../calificacion/presentation/widgets/stars_rating_widget.dart';
import '../../../discusion/presentation/screens/discusion_screen.dart';
import '../../../ejercicio/presentation/screens/ejercicios_screen.dart';

class CursoDetailScreen extends StatefulWidget {
  const CursoDetailScreen({super.key});

  @override
  State<CursoDetailScreen> createState() => _CursoDetailScreenState();
}

class _CursoDetailScreenState extends State<CursoDetailScreen> {
  int _selectedTab = 0; // 0: Lecciones, 1: Ejercicios, 2: Discusión

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB), 
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeaderImage(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndProgress(),
                      const SizedBox(height: 24),
                      
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      
                      _buildTabs(),
                      const SizedBox(height: 24),
                      
                      // Render Dinámico según la Pestaña
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: _selectedTab == 0
                            ? Container(
                                key: const ValueKey(0),
                                child: _buildLeccionesContent(),
                              )
                            : _selectedTab == 1
                                ? const EjerciciosScreen(key: ValueKey(1))
                                : Container(
                                    key: const ValueKey(2),
                                    child: _buildDiscusionContent(),
                                  ),
                      ),

                      const SizedBox(height: 100), // Espacio para NavBar
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Transform.scale(
                scale: 1.15,
                child: Image.network(
                  'http://localhost:3845/assets/2f178e062fbcf7ac085cd51914ceac0bc82eacc2.png', 
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularIconButton(Icons.arrow_back, () => Navigator.pop(context)),
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
          color: const Color(0xFF6BCA54).withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildTitleAndProgress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ejemplo De Curso',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFF6BCA54),
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ema Nuel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFF79AC63), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Estudiante', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  const Text('|  4.5', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 65,
          height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  value: 0.2,
                  strokeWidth: 6,
                  backgroundColor: Color(0xFFD9D9D9),
                  color: Color(0xFF4DC130),
                  strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                ),
              ),
              Text('20%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF606F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.black87, size: 28),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Creación', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('1 Marzo 2026', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEB95C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_border, color: Colors.black87, size: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rate: 4.5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('167 comentarios', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
          _buildTabItem('Lecciones', 0),
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
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
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

  Widget _buildDiscusionContent() {
    return Column(
      children: const [
        SizedBox(height: 10),
        StarsRatingWidget(),
        SizedBox(height: 24),
        DiscusionScreen(),
      ],
    );
  }

  Widget _buildLeccionesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Introducción" section
        const Text('Introducción', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean sed diam urna tempor pulvinar vivamus fringilla lacus nec metus bibendum egestas iaculis massa nisl malesuada lacinia integer nunc posuere ut hendrerit.',
          style: TextStyle(fontSize: 14, color: Color(0xFF787878), fontWeight: FontWeight.w600, height: 1.4),
        ),
        const SizedBox(height: 32),
        const Text('Lecciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildLeccionCard(
          category: 'Cálculo diferencial',
          categoryColor: const Color(0xFF6BC654),
          title: 'Derivadas',
          duration: '1 Hora',
          rating: '4.9',
          students: '1.200 estudiantes',
          progress: 0.2, // 20%
          imageUrl: 'https://picsum.photos/150/150?random=10', // Placeholder
        ),
        const SizedBox(height: 12),
        _buildLeccionCard(
          category: 'JAVA',
          categoryColor: const Color(0xFF4DC130).withOpacity(0.8),
          category2: 'P.O.O',
          categoryColor2: const Color(0xFFFF606F).withOpacity(0.74),
          title: 'Herencia',
          duration: '1 Hora',
          rating: '4.9',
          students: '1.200 estudiantes',
          progress: 0.2,
          imageUrl: 'https://picsum.photos/150/150?random=11',
        ),
        const SizedBox(height: 12),
        _buildLeccionCard(
          category: 'Cálculo diferencial',
          categoryColor: const Color(0xFFF6B55C).withOpacity(0.69),
          title: 'Derivadas',
          duration: '1 Hora',
          rating: '4.9',
          students: '1.200 estudiantes',
          progress: 0.2,
          imageUrl: 'https://picsum.photos/150/150?random=12',
        ),
      ],
    );
  }

  Widget _buildLeccionCard({
    required String category,
    Color categoryColor = const Color(0xFF6BC654),
    String? category2,
    Color? categoryColor2,
    required String title,
    required String duration,
    required String rating,
    required String students,
    required double progress,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/leccion_detail'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Padding dinámico y natural
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Imagen del curso / lección
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 74, height: 74, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 14),
            // Contenido en texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Categorías superpuestas
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                      if (category2 != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(category2, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(duration, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  // Rating y número de estudiantes
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 10, color: Colors.black26),
                      const SizedBox(width: 8),
                      Text(students, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            // Columna derecha: Corazón de favoritos y Progreso circular
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.favorite_border, color: Colors.redAccent, size: 20),
                const SizedBox(height: 12),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        color: const Color(0xFF4DC130),
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                      ),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
