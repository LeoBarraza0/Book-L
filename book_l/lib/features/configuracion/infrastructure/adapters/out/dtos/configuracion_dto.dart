import 'package:book_l/features/configuracion/domain/models/configuracion.dart';

class ConfiguracionDto {
  final int idConfig;
  final int idUsuario;
  final int tema;
  final String idioma;
  final int notificacionesPush;
  final int notificacionesEmail;
  final int notificacionesRacha;
  final String tamanoFuente;
  final int reproduccionAuto;
  final int perfilPublico;

  ConfiguracionDto({
    required this.idConfig,
    required this.idUsuario,
    required this.tema,
    required this.idioma,
    required this.notificacionesPush,
    required this.notificacionesEmail,
    required this.notificacionesRacha,
    required this.tamanoFuente,
    required this.reproduccionAuto,
    required this.perfilPublico,
  });

  static int _parseIntOrBool(dynamic value, {int defaultValue = 0}) {
    if (value is bool) return value ? 1 : 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  factory ConfiguracionDto.fromJson(Map<String, dynamic> json) {
    return ConfiguracionDto(
      idConfig: _parseIntOrBool(json['idconfig'] ?? json['id_config'], defaultValue: 0),
      idUsuario: _parseIntOrBool(json['idusuario'] ?? json['id_usuario'], defaultValue: 0),
      tema: _parseIntOrBool(json['tema'], defaultValue: 0),
      idioma: json['idioma'] as String? ?? 'es',
      notificacionesPush: _parseIntOrBool(json['notificaciones_push'], defaultValue: 1),
      notificacionesEmail: _parseIntOrBool(json['notificaciones_email'], defaultValue: 1),
      notificacionesRacha: _parseIntOrBool(json['notificaciones_racha'], defaultValue: 1),
      tamanoFuente: json['tamano_fuente'] as String? ?? 'normal',
      reproduccionAuto: _parseIntOrBool(json['reproduccion_auto'], defaultValue: 1),
      perfilPublico: _parseIntOrBool(json['perfil_publico'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idconfig': idConfig,
      'idusuario': idUsuario,
      'tema': tema,
      'idioma': idioma,
      'notificaciones_push': notificacionesPush,
      'notificaciones_email': notificacionesEmail,
      'notificaciones_racha': notificacionesRacha,
      'tamano_fuente': tamanoFuente,
      'reproduccion_auto': reproduccionAuto,
      'perfil_publico': perfilPublico,
    };
  }

  Configuracion toEntity() {
    return Configuracion(
      idConfig: idConfig,
      idUsuario: idUsuario,
      temaOscuro: tema == 1,
      idioma: idioma,
      notificacionesPush: notificacionesPush == 1,
      notificacionesEmail: notificacionesEmail == 1,
      notificacionesRacha: notificacionesRacha == 1,
      tamanoFuente: tamanoFuente,
      reproduccionAuto: reproduccionAuto == 1,
      perfilPublico: perfilPublico == 1,
    );
  }

  static ConfiguracionDto fromEntity(Configuracion entity) {
    return ConfiguracionDto(
      idConfig: entity.idConfig,
      idUsuario: entity.idUsuario,
      tema: entity.temaOscuro ? 1 : 0,
      idioma: entity.idioma,
      notificacionesPush: entity.notificacionesPush ? 1 : 0,
      notificacionesEmail: entity.notificacionesEmail ? 1 : 0,
      notificacionesRacha: entity.notificacionesRacha ? 1 : 0,
      tamanoFuente: entity.tamanoFuente,
      reproduccionAuto: entity.reproduccionAuto ? 1 : 0,
      perfilPublico: entity.perfilPublico ? 1 : 0,
    );
  }
}
