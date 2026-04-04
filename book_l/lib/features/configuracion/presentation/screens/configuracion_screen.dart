import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top section (Header, Profile)
                _buildTopSection(context),

                // Settings List in a white rounded container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Configuración'),
                          _buildSettingTile(
                            icon: Icons.brightness_6_outlined,
                            iconColor: const Color(0xFF96D786),
                            title: 'Configuración del tema',
                          ),
                          _buildSettingTile(
                            icon: Icons.text_fields,
                            iconColor: const Color(0xFFF6B55C),
                            title: 'Tamaño de letra',
                          ),
                          _buildSettingTile(
                            icon: Icons.swap_vert,
                            iconColor: const Color(0xFF555555),
                            title: 'Auto Scroll',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('Soporte'),
                          _buildSettingTile(
                            icon: Icons.chat_bubble_outline,
                            iconColor: const Color(0xFF4DC130),
                            title: 'PQRS',
                          ),
                          _buildSettingTile(
                            icon: Icons.headset_mic_outlined,
                            iconColor: const Color(0xFFFFB74D),
                            title: 'Contactanos',
                          ),

                          const SizedBox(height: 20),
                          _buildSectionTitle('Cuenta'),
                          _buildSettingTile(
                            icon: Icons.logout,
                            iconColor: const Color(0xFFFF606F),
                            title: 'Cerrar sesión',
                            isDestructive: true,
                          ),

                          const SizedBox(
                            height: 100,
                          ), // Reserve space for bottom nav
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Bottom Navigation Bar
            const Positioned(
              left: 20,
              right: 20,
              bottom: 30, // Elevated off bottom
              child:
                  SharedBottomNavBar(), // Index 2 is "Perfil" in the SharedBottomNavBar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with back button
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF96D786), // Consistent with home buttons
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    // Navigate to Home as requested
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Perfil Estudiante',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Space balance for true centering
            ],
          ),
          const SizedBox(height: 20),

          // Profile Picture
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF4DC130), width: 3),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4DC130),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // User Name
          const Text(
            'Emanuel Barranco',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),

          const SizedBox(height: 12),

          // Ver perfil Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DC130),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Ver perfil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          // Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive
                    ? const Color(0xFFFF606F)
                    : const Color(0xFF424242),
              ),
            ),
          ),
          // Chevron
          const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
        ],
      ),
    );
  }
}
