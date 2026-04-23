import 'package:flutter/material.dart';

class ChatbotActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color contentColor;
  final VoidCallback onTap;

  const ChatbotActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.contentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                subtitle!,
                style: TextStyle(
                  fontSize: 10,
                  color: contentColor.withValues(alpha: 0.9), // Changed from withOpacity
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
