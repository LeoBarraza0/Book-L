import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthRecoveryHeader extends StatelessWidget {
  final String title;

  const AuthRecoveryHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Botón volver
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DC130).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Color(0xFF4DC130),
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            SvgPicture.asset(
              'assets/images/padlock_icon.svg',
              height: 90,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 20),

            // 📝 Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A4A4A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
