import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/notificacion/domain/models/notificacion.dart';
import 'package:book_l/features/notificacion/application/ports/out/notificacion_repository.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/out/dtos/notificacion_dto.dart';
import 'package:flutter/foundation.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  @override
  Future<List<Notificacion>> getNotificaciones(int idUsuario) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_notificacion')
            .select()
            .eq('idusuariofk', idUsuario);
        return res
            .map((json) => NotificacionDto.fromJson(json).toEntity())
            .toList();
      } catch (e) {
        if (kDebugMode) print('Error getNotificaciones Supabase: $e');
      }
    }

    // Simulando latencia
    await Future.delayed(const Duration(milliseconds: 300));
    final service = BooklService();
    final data = service.notificaciones
        .where((n) => n['id_usuario_fk'] == idUsuario)
        .toList();

    return data
        .map((json) => NotificacionDto.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> marcarComoLeidas(int idUsuario) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_notificacion')
            .update({'leida': true})
            .eq('idusuariofk', idUsuario);
      } catch (e) {
        if (kDebugMode) print('Error marcarComoLeidas Supabase: $e');
      }
    }
    BooklService().marcarNotificacionesComoLeidas(idUsuario);
  }
}
