import '../../domain/entities/configuracion.dart';

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

  factory ConfiguracionDto.fromJson(Map<String, dynamic> json) {
    return ConfiguracionDto(
      idConfig: json['id_config'] as int? ?? 0,
      idUsuario: json['id_usuario'] as int? ?? 0,
      tema: json['tema'] as int? ?? 0,
      idioma: json['idioma'] as String? ?? 'es',
      notificacionesPush: json['notificaciones_push'] as int? ?? 1,
      notificacionesEmail: json['notificaciones_email'] as int? ?? 1,
      notificacionesRacha: json['notificaciones_racha'] as int? ?? 1,
      tamanoFuente: json['tamano_fuente'] as String? ?? 'normal',
      reproduccionAuto: json['reproduccion_auto'] as int? ?? 1,
      perfilPublico: json['perfil_publico'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_config': idConfig,
      'id_usuario': idUsuario,
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
