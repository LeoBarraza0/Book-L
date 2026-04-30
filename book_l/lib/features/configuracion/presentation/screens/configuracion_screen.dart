import 'package:flutter/material.dart';

import '../../../perfil/presentation/screens/perfil_screen.dart';
import '../controller/configuracion_controller.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../shared/widgets/custom_avatar.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final ConfiguracionController _controller = ConfiguracionController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4DC130),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Configuración'),
                                _buildSwitchTile(
                                  icon: Icons.brightness_6_outlined,
                                  iconColor: const Color(0xFF96D786),
                                  title: 'Tema oscuro',
                                  value:
                                      _controller.config?.temaOscuro ?? false,
                                  onChanged: (val) {
                                    _controller.updateTemaOscuro(val);
                                  },
                                ),
                                _buildDropdownTile(
                                  icon: Icons.text_fields,
                                  iconColor: const Color(0xFFF6B55C),
                                  title: 'Tamaño de letra',
                                  currentValue:
                                      _controller.config?.tamanoFuente ??
                                          'normal',
                                  options: ['pequeno', 'normal', 'grande'],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _controller.updateTamanoFuente(val);
                                    }
                                  },
                                ),
                                _buildSwitchTile(
                                  icon: Icons.swap_vert,
                                  iconColor: const Color(0xFF555555),
                                  title:
                                      'Reproducción automática (Auto Scroll)',
                                  value: _controller.config?.reproduccionAuto ??
                                      true,
                                  onChanged: (val) {
                                    _controller.updateReproduccionAuto(val);
                                  },
                                ),

                                const SizedBox(height: 20),
                                _buildSectionTitle('Soporte'),
                                _buildActionTile(
                                  icon: Icons.chat_bubble_outline,
                                  iconColor: const Color(0xFF4DC130),
                                  title: 'PQRS',
                                  onTap: () {
                                    // Navigate to the Suggestion (PQRS) screen
                                    Navigator.pushNamed(context, '/sugerencia');
                                  },
                                ),
                                _buildActionTile(
                                  icon: Icons.headset_mic_outlined,
                                  iconColor: const Color(0xFFFFB74D),
                                  title: 'Contáctanos',
                                  onTap: () {
                                    _showContactanosDialog(context);
                                  },
                                ),

                                const SizedBox(height: 20),
                                _buildSectionTitle('Cuenta'),
                                _buildActionTile(
                                  icon: Icons.logout,
                                  iconColor: const Color(0xFFFF606F),
                                  title: 'Cerrar sesión',
                                  isDestructive: true,
                                  onTap: () {
                                    _showLogoutConfirmDialog(context);
                                  },
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
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    final session = AppSession();
    final rolStr = session.rol ?? 'Estudiante';
    final nombreStr = session.nombreCompleto ?? 'Usuario';

    String? avatarUrl;
    try {
      final user = BooklService()
          .usuarios
          .firstWhere((u) => u.idUsuario == session.usuarioId);
      avatarUrl = user.avatarUrl;
    } catch (_) {}

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
                  color: Color(0xFF96D786),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Perfil $rolStr',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                child: CustomAvatar(
                  url: avatarUrl,
                  nombre: nombreStr,
                  radius: 50,
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
          Text(
            nombreStr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
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

  void _showContactanosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Contáctanos',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Si necesitas ayuda, puedes comunicarte con nuestro equipo de soporte a través de:'),
              SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.email, color: Color(0xFF4DC130)),
                  SizedBox(width: 10),
                  Text('soporte@bookl.com',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Color(0xFF4DC130)),
                  SizedBox(width: 10),
                  Text('+57 300 123 4567',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar',
                  style: TextStyle(color: Color(0xFF4DC130))),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro que deseas salir de tu cuenta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _controller.cerrarSesion();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF606F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Salir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4DC130),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentValue,
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).cardColor,
            items: options.map((String value) {
              String label = value;
              if (value == 'pequeno') label = 'Pequeño';
              if (value == 'normal') label = 'Normal';
              if (value == 'grande') label = 'Grande';
              return DropdownMenuItem<String>(
                value: value,
                child: Text(label),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, top: 5),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? const Color(0xFFFF606F)
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }
}
