import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';

class CapituloScreen extends StatelessWidget {
  const CapituloScreen({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introducción
                      const Text('Introducción',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean sed diam urna tempor pulvinar vivamus fringilla lacus nec metus bibendum egestas iaculis massa nisl malesuada lacinia integer nunc posuere ut hendrerit.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787878),
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                      const SizedBox(height: 36),

                      // Título Principal
                      const Text('¿Qué son las derivadas?',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787878),
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                      const SizedBox(height: 28),

                      // Video Thumbnail Placeholder
                      Container(
                        height: 192,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.play_circle_fill, size: 48, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Subtítulo Lorem Ipsum
                      const Text('Lorem ipsum',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Dos cuadros grises
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 94,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Container(
                              height: 94,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Texto extra
                      const Text(
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787878),
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                      const SizedBox(height: 24),

                      // Fórmula Rectángulo
                      Container(
                        height: 94,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('√(x + y)',
                            style: TextStyle(
                                fontSize: 32,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787878),
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean.',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF787878),
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),

                      const SizedBox(height: 64),

                      // Sección de Pruebas
                      const Center(
                        child: Text('¡Pon a prueba tus conocimientos!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPruebaButton('1'),
                          _buildPruebaButton('2'),
                        ],
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
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Transform.scale(
                scale: 1.15,
                child: Image.asset(
                  'assets/images/green_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[400]),
                ),
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
          color: const Color(0xFF6BCA54).withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildPruebaButton(String number) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFF606F), Color(0xFFFF8B96)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Realizar prueba',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF565656),
          ),
        ),
      ],
    );
  }
}
