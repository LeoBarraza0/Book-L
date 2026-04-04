import 'package:flutter/material.dart';

class SharedBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const SharedBottomNavBar({super.key, this.selectedIndex = -1});

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
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Buscar',
            isSelected: selectedIndex == 1,
          ),

          // Botón Circular Central (+)
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF4DC130),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),

          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            isSelected: selectedIndex == 2,
            onTap: () {
              if (selectedIndex != 2) {
                Navigator.pushReplacementNamed(context, '/perfil');
              }
            },
          ),
          _buildNavItem(
            icon: Icons.bookmark_outline,
            label: 'Booki',
            isSelected: selectedIndex == 3,
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
          color: isSelected ? const Color(0xFF4DC130) : const Color(0xFF676767),
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
