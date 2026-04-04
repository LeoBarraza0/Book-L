import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';

class NotificacionScreen extends StatelessWidget {
  const NotificacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB), // Using home's background color
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF96D786,
                          ), // Consistent with home buttons
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      Image.asset(
                        'assets/images/notification.png',
                        width: 280,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.notifications_active,
                            size: 100,
                            color: Color(0xFF4DC130),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Texts
                      const Text(
                        '¡No hay nada que mostrar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF4DC130),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'No hay notificaciones. ¡Te notificaremos cuando algo nuevo pase!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 100,
                      ), // Reserve space for the floating nav bar
                    ],
                  ),
                ),
              ],
            ),

            // Floating Bottom Navigation Bar
            const Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: SharedBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}
