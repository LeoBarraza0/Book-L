import 'package:flutter/material.dart';

/// Botón verde reutilizable con el estilo de Book-L.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 52,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4DC130),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 3,
          shadowColor: const Color(0xFF4DC130).withOpacity(0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
