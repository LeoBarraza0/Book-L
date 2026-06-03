import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/configuracion/domain/models/configuracion.dart';
import 'package:book_l/features/configuracion/application/ports/out/configuracion_repository.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/out/dtos/configuracion_dto.dart';
import 'package:flutter/foundation.dart';

class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  final BooklService _service = BooklService();

  Map<String, dynamic> _toSupabaseMap(Configuracion config) {
    return {
      'idusuario': config.idUsuario,
      'tema': config.temaOscuro,
      'idioma': config.idioma,
      'notificaciones_push': config.notificacionesPush,
      'notificaciones_email': config.notificacionesEmail,
      'notificaciones_racha': config.notificacionesRacha,
      'tamano_fuente': config.tamanoFuente,
      'reproduccion_auto': config.reproduccionAuto,
      'perfil_publico': config.perfilPublico,
    };
  }

  @override
  Configuracion getConfiguracionByUsuario(int idUsuario) {
    if (SupabaseClientHelper.isConfigured) {
      // Async fetching would require changing the signature, so we just
      // fire a background sync and return local.
      SupabaseClientHelper.client
          .from('tbl_configuracion')
          .select()
          .eq('idusuario', idUsuario)
          .maybeSingle()
          .then((res) {
        if (res != null) {
          final conf = ConfiguracionDto.fromJson(res).toEntity();
          _service.saveConfiguracion(conf);
        }
      }).catchError((e) {
        if (kDebugMode) print('Error getConfiguracionByUsuario Supabase: $e');
      });
    }

    try {
      return _service.configuraciones
          .firstWhere((c) => c.idUsuario == idUsuario);
    } catch (e) {
      return Configuracion(
        idConfig: _service.generateId(),
        idUsuario: idUsuario,
        temaOscuro: false,
        idioma: 'es',
        notificacionesPush: true,
        notificacionesEmail: true,
        notificacionesRacha: true,
        tamanoFuente: 'normal',
        reproduccionAuto: true,
        perfilPublico: true,
      );
    }
  }

  @override
  Future<void> saveConfiguracion(Configuracion config) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final existing = await SupabaseClientHelper.client
            .from('tbl_configuracion')
            .select('idconfig')
            .eq('idusuario', config.idUsuario)
            .maybeSingle();

        if (existing != null) {
          await SupabaseClientHelper.client
              .from('tbl_configuracion')
              .update(_toSupabaseMap(config))
              .eq('idconfig', existing['idconfig']);
        } else {
          await SupabaseClientHelper.client
              .from('tbl_configuracion')
              .insert(_toSupabaseMap(config));
        }
      } catch (e) {
        if (kDebugMode) print('Error saveConfiguracion Supabase: $e');
      }
    }
    _service.saveConfiguracion(config);
  }

  @override
  Future<void> enviarSugerencia(Map<String, dynamic> sugerencia) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_sugerencia').insert({
          'id_usuariofk': sugerencia['id_usuario'],
          'contenido': sugerencia['mensaje'],
          'tipo': sugerencia['tipo'] ?? 'general',
        });
      } catch (e) {
        if (kDebugMode) print('Error enviarSugerencia Supabase: $e');
      }
    }
    
    // Agregamos el ID generado aquí para mantener la lógica de persistencia encapsulada
    sugerencia['id_sugerencia'] = _service.generateId();
    _service.saveSugerencia(sugerencia);
  }
}
