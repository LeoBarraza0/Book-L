import 'package:flutter/material.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/controller/auth_controller.dart';
import 'package:book_l/features/notificacion/domain/models/notificacion.dart';
import 'package:book_l/features/notificacion/application/usecases/get_notificaciones_usecase.dart';
import 'package:book_l/features/notificacion/application/usecases/mark_as_read_usecase.dart';

class NotificacionesController extends ChangeNotifier {
  final GetNotificacionesUseCase getNotificacionesUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final AuthController authController;

  List<Notificacion> _notificaciones = [];
  bool isLoading = false;
  String errorMessage = '';

  NotificacionesController({
    required this.getNotificacionesUseCase,
    required this.markAsReadUseCase,
    required this.authController,
  }) {
    // Escuchar cambios en BooklService para actualizar las notificaciones en tiempo real si ocurren
    BooklService().addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    BooklService().removeListener(_onServiceUpdate);
    super.dispose();
  }

  List<Notificacion> get notificaciones => _notificaciones;

  int get unreadCount => _notificaciones.where((n) => !n.leida).length;

  void _onServiceUpdate() {
    // Si BooklService cambia (ej. nuevo follow), recargamos las notificaciones
    loadNotificaciones(silently: true);
  }

  Future<void> loadNotificaciones({bool silently = false}) async {
    final userId = authController.usuarioActual?.idUsuario;
    if (userId == null) return;

    if (!silently) {
      isLoading = true;
      errorMessage = '';
      notifyListeners();
    }

    try {
      final result = await getNotificacionesUseCase(userId);
      // Ordenar por fecha descendente
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _notificaciones = result;
    } catch (e) {
      if (!silently) errorMessage = e.toString();
    } finally {
      if (!silently) isLoading = false;
      notifyListeners();
    }
  }

  Future<void> marcarComoLeidas() async {
    final userId = authController.usuarioActual?.idUsuario;
    if (userId == null) return;

    // Evitar llamada innecesaria si ya no hay sin leer
    if (unreadCount == 0) return;

    try {
      await markAsReadUseCase(userId);
      // Actualizamos estado local
      _notificaciones =
          _notificaciones.map((n) => n.copyWith(leida: true)).toList();
      notifyListeners();
    } catch (e) {
      // Manejar error silente
    }
  }
}
