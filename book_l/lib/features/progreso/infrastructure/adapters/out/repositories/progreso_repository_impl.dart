import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/progreso/application/ports/out/progreso_repository.dart';
import 'package:flutter/foundation.dart';

class ProgresoRepositoryImpl implements ProgresoRepository {
  final _service = BooklService();

  @override
  Future<dynamic> getProgreso(int idUsuario) async {
    int rachaValue = 0;
    int capitulos = AppSession().completedCapitulos.value.length;
    int ejercicios = AppSession().completedEjercicios.value.length;
    List<String> diasActividad = [];

    if (SupabaseClientHelper.isConfigured) {
      try {
        final rachaRes = await SupabaseClientHelper.client
            .from('tbl_racha')
            .select()
            .eq('id_usuario', idUsuario)
            .maybeSingle();
            
        if (rachaRes != null) {
          rachaValue = rachaRes['current_streak'] ?? 0;
        }

        final capRes = await SupabaseClientHelper.client
            .from('tbl_progreso_usuario')
            .select('id_progreso')
            .eq('id_usuariofk', idUsuario)
            .eq('estado', 'completada');
        capitulos = capRes.length;

        final eventosRes = await SupabaseClientHelper.client
            .from('tbl_evento_aprendizaje')
            .select('fecha_evento')
            .eq('id_usuario', idUsuario)
            .order('fecha_evento', ascending: false)
            .limit(30);
            
        diasActividad = eventosRes
            .map((e) => (e['fecha_evento'] as String).split('T').first)
            .toSet()
            .toList();

        // Update local state if needed
      } catch (e) {
        if (kDebugMode) print('Error getProgreso Supabase: $e');
        final racha = _service.getRacha(idUsuario);
        rachaValue = racha?['racha_actual'] ?? 0;
        diasActividad = List<String>.from(racha?['dias_actividad'] ?? []);
      }
    } else {
      final racha = _service.getRacha(idUsuario);
      rachaValue = racha?['racha_actual'] ?? 0;
      diasActividad = List<String>.from(racha?['dias_actividad'] ?? []);
    }

    return {
      'racha': rachaValue,
      'capitulos_completados': capitulos,
      'ejercicios_completados': ejercicios,
      'dias_actividad': diasActividad,
    };
  }

  @override
  Future<void> actualizarProgreso(
      int idUsuario, int idEntidad, String tipoEntidad) async {
    if (tipoEntidad == 'capitulo') {
      AppSession().marcarCapituloCompletado(idEntidad, true);

      if (SupabaseClientHelper.isConfigured) {
        try {
          final res = await SupabaseClientHelper.client
              .from('tbl_progreso_usuario')
              .select('id_progreso')
              .eq('id_usuariofk', idUsuario)
              .eq('id_capitulofk', idEntidad)
              .maybeSingle();

          if (res != null) {
            await SupabaseClientHelper.client
                .from('tbl_progreso_usuario')
                .update({'estado': 'completada', 'porcentaje_capitulo': 100})
                .eq('id_progreso', res['id_progreso']);
          } else {
            await SupabaseClientHelper.client.from('tbl_progreso_usuario').insert({
              'id_usuariofk': idUsuario,
              'id_capitulofk': idEntidad,
              'estado': 'completada',
              'porcentaje_capitulo': 100
            });
          }
        } catch (e) {
          if (kDebugMode) print('Error actualizarProgreso Supabase: $e');
        }
      }

      // Sincronizar con BooklService.progresoUsuario
      final idx = _service.progresoUsuario.indexWhere((p) =>
          p['id_usuario_fk'] == idUsuario && p['id_capitulo_fk'] == idEntidad);
      if (idx != -1) {
        _service.progresoUsuario[idx]['estado'] = 'completada';
      } else {
        _service.progresoUsuario.add({
          'id_usuario_fk': idUsuario,
          'id_capitulo_fk': idEntidad,
          'estado': 'completada',
        });
      }
      _service.guardarDatos();
    } else if (tipoEntidad == 'ejercicio') {
      AppSession().marcarEjercicioCompletado(idEntidad, idUsuario);
    }
  }

  @override
  Future<void> registrarEvento(int idUsuario, String tipoEvento) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_evento_aprendizaje').insert({
          'id_usuario': idUsuario,
          'tipo_evento': tipoEvento,
        });
        
        // Actualizar racha en Supabase (simplificado)
        final rachaRes = await SupabaseClientHelper.client
            .from('tbl_racha')
            .select()
            .eq('id_usuario', idUsuario)
            .maybeSingle();
            
        final today = DateTime.now().toIso8601String().split('T').first;
        if (rachaRes != null) {
          final lastDate = rachaRes['last_activity_date'];
          if (lastDate != today) {
            int current = rachaRes['current_streak'] ?? 0;
            if (lastDate == DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first) {
              current += 1;
            } else {
              current = 1;
            }
            int max = rachaRes['max_streak'] ?? 0;
            if (current > max) max = current;
            
            await SupabaseClientHelper.client.from('tbl_racha').update({
              'current_streak': current,
              'max_streak': max,
              'last_activity_date': today,
            }).eq('id_racha', rachaRes['id_racha']);
          }
        } else {
          await SupabaseClientHelper.client.from('tbl_racha').insert({
            'id_usuario': idUsuario,
            'current_streak': 1,
            'max_streak': 1,
            'last_activity_date': today,
          });
        }
      } catch (e) {
        if (kDebugMode) print('Error registrarEvento Supabase: $e');
      }
    }
    _service.registrarActividad(idUsuario);
  }
}
