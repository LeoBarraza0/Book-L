import 'package:flutter/material.dart';

class FeedbackUtils {
  // ── Snackbars ─────────────────────────────────────────────────────────────

  static void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFF4DC130),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFFF5252),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.info_outline_rounded,
      backgroundColor: Colors.blueAccent,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.black54, fontFamily: 'Inter'),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : const Color(0xFF4DC130),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
