import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          Column(
            children: [
              // Header blanco superior, pegado al borde y con esquinas redondeadas abajo
              _buildHeader(context),

              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Ilustración de Buki central (sin marca de agua, solo en medio)
                      Image.asset(
                        'assets/images/Chatbot_Icon.png',
                        height: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.smart_toy,
                            size: 100,
                            color: Color(0xFF4DC130),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Saludo centrado
                      const Text(
                        'Hola, Emanuel',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF96D786), // Verde claro como en figma
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '¿How can assist you today?',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF212121),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Opciones de acción sugeridas
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                title: 'Cómo usar la app',
                                subtitle:
                                    'Instructivo de uso y algunas cosas útiles',
                                icon: Icons.offline_bolt_outlined,
                                backgroundColor: const Color(
                                  0xFFC4E69D,
                                ), // Verde pastel
                                contentColor: const Color(0xFF5A5A5A),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                title: 'Cómo crear una\nlección',
                                icon: Icons.draw_outlined,
                                backgroundColor: const Color(
                                  0xFFF6AAB1,
                                ), // Rosa pastel
                                contentColor: const Color(0xFF5A5A5A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 160,
                      ), // Espacio extra para el chat input y la barra navbar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Contenedor grande del input de chat
          Positioned(
            bottom: 110, // Arriba del navbar
            left: 20,
            right: 20,
            child: _buildChatInput(),
          ),

          // Bottom Navigation Bar
          const Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SharedBottomNavBar(selectedIndex: 3),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header Blanco Superior
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      // Padding dinámico sumando el notch/status bar
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        children: [
          // Botón Atrás
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF96D786),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  final role = BooklService().currentRole;
                  Navigator.pushReplacementNamed(
                    context,
                    role == 'admin' ? '/admin_Home' : '/home',
                  );
                }
              },
            ),
          ),

          // Título Centrado
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Booki',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF4DC130),
                      size: 20,
                    ),
                  ],
                ),
                const Text(
                  'Chatbot asistente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),

          // Espaciador del mismo ancho que el botón Atrás para centrar el texto exactamente
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tarjetas de Acciones Rápidas
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActionCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color contentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: contentColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: contentColor,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: contentColor.withOpacity(0.9),
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Input de Mensaje de Chat (Grande)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildChatInput() {
    return Container(
      height: 120, // Altura más grande como en el Figma
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _messageController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: 'What would you like to know?',
              hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF4DC130),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.send_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  _messageController.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
