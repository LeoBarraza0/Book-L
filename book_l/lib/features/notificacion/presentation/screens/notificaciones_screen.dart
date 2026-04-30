import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../data/repositories/notificacion_repository_impl.dart';
import '../../domain/usecases/get_notificaciones_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../controller/notificaciones_controller.dart';
import '../../domain/entities/notificacion.dart';

class NotificacionScreen extends StatefulWidget {
  const NotificacionScreen({super.key});

  @override
  State<NotificacionScreen> createState() => _NotificacionScreenState();
}

class _NotificacionScreenState extends State<NotificacionScreen> {
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
    _controller.loadNotificaciones().then((_) {
      // Marcar como leídas una vez que se han cargado en la UI
      _controller.marcarComoLeidas();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} d';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} h';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} min';
    return 'Hace un momento';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB), // Using home's background color
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF96D786), // Consistent with home buttons
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              final role = BooklService().currentRole;
                              Navigator.pushReplacementNamed(
                                  context, role == 'admin' ? '/admin_Home' : '/home');
                            }
                          },
                        ),
                      ),
                      const Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      if (_controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DC130),
                          ),
                        );
                      }

                      if (_controller.errorMessage.isNotEmpty) {
                        return Center(
                          child: Text(
                            'Error: ${_controller.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (_controller.notificaciones.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100, top: 10),
                        itemCount: _controller.notificaciones.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(
                              context, _controller.notificaciones[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Floating Bottom Navigation Bar
            const Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: SharedBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Illustration
        Image.asset(
          'assets/images/notification.png',
          width: 280,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.notifications_active,
              size: 100,
              color: Color(0xFF4DC130),
            );
          },
        ),

        const SizedBox(height: 40),

        // Texts
        const Text(
          '¡No hay nada que mostrar!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF4DC130),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'No hay notificaciones. ¡Te notificaremos cuando algo nuevo pase!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(
          height: 100,
        ), // Reserve space for the floating nav bar
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, Notificacion notif) {
    // Si la notificación es tipo follow, obtenemos los datos del usuario que siguió
    final user = BooklService()
        .usuarios
        .where((u) => u.idUsuario == notif.idReferencia)
        .firstOrNull;

    return GestureDetector(
      onTap: () {
        if (notif.tipo == 'follow' && user != null) {
          Navigator.pushNamed(
            context,
            '/usuario_perfil',
            arguments: <String, String>{
              'name': user.nombreCompleto,
              'username': user.nombreCompleto, // Or username if available
              'imageUrl': user.avatarUrl ?? '',
              'idUsuario': user.idUsuario.toString(),
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                shape: BoxShape.circle,
                image: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(user.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Color(0xFF44BD32), size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.mensaje,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRelativeTime(notif.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (!notif.leida)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF606F),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
