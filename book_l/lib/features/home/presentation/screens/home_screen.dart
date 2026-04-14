import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          // ── Contenido Principal (Scroll) ─────────────────────────────
          CustomScrollView(
            slivers: [
              // Header blanco superior
              SliverToBoxAdapter(child: _buildTopHeader(context)),

              // Sección de Bienvenida
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido, Emanuel!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tenemos algunos materiales que podría ser de tu agrado:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Racha Buky
                      _buildRachaCard(),
                      const SizedBox(height: 24),

                      // Lista de Materiales
                      _buildMaterialCard(
                        context: context,
                        title: 'Vectores Bidimencionales',
                        categoryLabel: 'Cálculo diferencial',
                        badgeLabel: 'Nuevo',
                        badgeColor: const Color(0xFFF6B55C),
                        imageUrl:
                            'http://localhost:3845/assets/8c82a4b652fc817b4e269031a428e684d5d7d999.png',
                      ),
                      const SizedBox(height: 20),
                      _buildMaterialCard(
                        context: context,
                        title: 'Tipo de leyes en Colombia',
                        categoryLabel: 'Derecho',
                        badgeLabel: 'Derecho',
                        badgeColor: const Color(0xFFFF606F),
                        imageUrl:
                            'http://localhost:3845/assets/c2656cc2eff92737828dbe3c8a53f7a960cf56d3.png',
                      ),
                      const SizedBox(height: 20),
                      _buildMaterialCard(
                        context: context,
                        title: 'Vectores Bidimencionales',
                        categoryLabel: 'Cálculo diferencial',
                        badgeLabel: 'Nuevo',
                        badgeColor: const Color(0xFFF6B55C),
                        imageUrl:
                            'http://localhost:3845/assets/8c82a4b652fc817b4e269031a428e684d5d7d999.png',
                      ),
                      const SizedBox(
                        height: 100,
                      ), // Espacio para el bottom nav bar
                    ],
                  ),
                ),
              ),
            ],
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
  // Header superior blanco
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        50,
        20,
        20,
      ), // Padding para el SafeArea
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Ajustes
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/configuracion');
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF96D786),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),

          // Logo Central
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 60,
            fit: BoxFit.contain,
          ),

          // Botón Notificaciones
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notificaciones');
            },
            child: Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF96D786),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF949F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tarjeta de "Racha Buky"
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRachaCard() {
    final dias = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    // Marcamos los primeros 6 días como logrados (por ejemplo)
    final logrados = [true, true, true, true, true, true, false];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar Buky (Búho verde)
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF96D786),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/racha.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.pets, color: Colors.green, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Textos y Racha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Saluda a tu Racha Buky!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '¡Completa una lección cada día para que tu racha crezca como tu conocimiento!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 12),
                // Círculos de días
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    return Column(
                      children: [
                        Text(
                          dias[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A5757),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: logrados[index]
                                ? const Color(0xFF96D786)
                                : const Color(0xFFB0B0B0),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tarjeta de Material (Cursos)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMaterialCard({
    required BuildContext context,
    required String title,
    required String categoryLabel,
    required String badgeLabel,
    required Color badgeColor,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/leccion_detail'),
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
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Row(
              children: [
                Icon(Icons.star, color: Color(0xFFF6B55C), size: 18),
                SizedBox(width: 4),
                Text(
                  '4.9',
                  style: TextStyle(
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
    );
  }
}
