import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/notificaciones_controller.dart';

class NotificationIconButton extends StatelessWidget {
  final Color iconColor;
  final Color badgeColor;
  final bool isGreenCircle; // Some views wrap it in a green circle
  final bool
      isWhiteCircle; // Some views wrap it in a white semi-transparent circle

  const NotificationIconButton({
    super.key,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFFF606F), // Reddish for contrast
    this.isGreenCircle = false,
    this.isWhiteCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final count = context.watch<NotificacionesController>().unreadCount;

    Widget iconWidget = Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          count > 0 ? Icons.notifications_active : Icons.notifications_none,
          color: iconColor,
          size: isGreenCircle ? 28 : 24, // Ajustar tamaño según uso
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    if (isGreenCircle) {
      return Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF96D786),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: iconWidget,
          onPressed: () {
            Navigator.pushNamed(context, '/notificaciones');
          },
        ),
      );
    } else if (isWhiteCircle) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: iconWidget,
          onPressed: () {
            Navigator.pushNamed(context, '/notificaciones');
          },
        ),
      );
    } else {
      return IconButton(
        icon: iconWidget,
        onPressed: () {
          Navigator.pushNamed(context, '/notificaciones');
        },
      );
    }
  }
}
