import 'package:flutter/material.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../data/repositories/notificacion_repository_impl.dart';
import '../../domain/usecases/get_notificaciones_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../controller/notificaciones_controller.dart';

class NotificationIconButton extends StatefulWidget {
  final Color iconColor;
  final Color badgeColor;
  final bool isGreenCircle; // Some views wrap it in a green circle
  final bool isWhiteCircle; // Some views wrap it in a white semi-transparent circle

  const NotificationIconButton({
    super.key,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFFF606F), // Reddish for contrast
    this.isGreenCircle = false,
    this.isWhiteCircle = false,
  });

  @override
  State<NotificationIconButton> createState() => _NotificationIconButtonState();
}

class _NotificationIconButtonState extends State<NotificationIconButton> {
  late final NotificacionesController _controller;

  @override
  void initState() {
    super.initState();
    final repo = NotificacionRepositoryImpl();
    _controller = NotificacionesController(
      getNotificacionesUseCase: GetNotificacionesUseCase(repo),
      markAsReadUseCase: MarkAsReadUseCase(repo),
      authController: AuthController(),
    );
    _controller.loadNotificaciones();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final count = _controller.unreadCount;

        Widget iconWidget = Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              count > 0 ? Icons.notifications_active : Icons.notifications_none,
              color: widget.iconColor,
              size: widget.isGreenCircle ? 28 : 24, // Ajustar tamaño según uso
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
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

        if (widget.isGreenCircle) {
          iconWidget = Container(
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
        } else if (widget.isWhiteCircle) {
          iconWidget = Container(
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
          iconWidget = IconButton(
            icon: iconWidget,
            onPressed: () {
              Navigator.pushNamed(context, '/notificaciones');
            },
          );
        }

        return iconWidget;
      },
    );
  }
}
