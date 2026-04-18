import 'package:flutter/material.dart';
import 'package:book_l/shared/widgets/create_menu_modal.dart' as lib_modal;

class SharedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final String role;

  const SharedBottomNavBar({
    super.key,
    this.selectedIndex = -1,
    this.role = 'user',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () {
              if (selectedIndex != 0) {
                if (role == 'admin') {
                  Navigator.pushReplacementNamed(context, '/admin_home');
                } else {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }
            },
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Buscar',
            isSelected: selectedIndex == 1,
            onTap: () {
              if (selectedIndex != 1) {
                if (role == 'admin') {
                  // Aún no hay pantalla de búsqueda para admin, hacemos print o nada
                  debugPrint('Buscar admin clickeado');
                } else {
                  Navigator.pushReplacementNamed(context, '/busqueda');
                }
              }
            },
          ),

          // Botón Circular Central (+)
          GestureDetector(
            onTap: () {
              if (role == 'admin') {
                 // Acciones de creación para admin si las hay
                 debugPrint('Crear admin clickeado');
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const lib_modal.CreateMenuModal();
                  },
                );
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF4DC130),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),

          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            isSelected: selectedIndex == 2,
            onTap: () {
              if (selectedIndex != 2) {
                if (role == 'admin') {
                  debugPrint('Perfil admin clickeado');
                } else {
                  Navigator.pushReplacementNamed(context, '/perfil');
                }
              }
            },
          ),
          _buildNavItem(
            icon: Icons.bookmark_outline,
            label: 'Booki', // O tal vez Notificaciones/Guardados para admin
            isSelected: selectedIndex == 3,
            onTap: () {
              if (selectedIndex != 3) {
                if (role == 'admin') {
                  debugPrint('Booki/Guardados admin clickeado');
                } else {
                  Navigator.pushReplacementNamed(context, '/chatbot');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF4DC130)
                : const Color(0xFF676767),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
               fontSize: 11,
               fontWeight: FontWeight.bold,
               color: isSelected
                   ? const Color(0xFF4DC130)
                   : const Color(0xFF676767),
            ),
          ),
        ],
      ),
    );
  }
}
