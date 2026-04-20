class Configuracion {
  final int idConfig;
  final int idUsuario;
  bool temaOscuro;
  String idioma;
  bool notificacionesPush;
  bool notificacionesEmail;
  bool notificacionesRacha;
  String tamanoFuente;
  bool reproduccionAuto;
  bool perfilPublico;

  Configuracion({
    required this.idConfig,
    required this.idUsuario,
    required this.temaOscuro,
    required this.idioma,
    required this.notificacionesPush,
    required this.notificacionesEmail,
    required this.notificacionesRacha,
    required this.tamanoFuente,
    required this.reproduccionAuto,
    required this.perfilPublico,
  });

  Configuracion copyWith({
    int? idConfig,
    int? idUsuario,
    bool? temaOscuro,
    String? idioma,
    bool? notificacionesPush,
    bool? notificacionesEmail,
    bool? notificacionesRacha,
    String? tamanoFuente,
    bool? reproduccionAuto,
    bool? perfilPublico,
  }) {
    return Configuracion(
      idConfig: idConfig ?? this.idConfig,
      idUsuario: idUsuario ?? this.idUsuario,
      temaOscuro: temaOscuro ?? this.temaOscuro,
      idioma: idioma ?? this.idioma,
      notificacionesPush: notificacionesPush ?? this.notificacionesPush,
      notificacionesEmail: notificacionesEmail ?? this.notificacionesEmail,
      notificacionesRacha: notificacionesRacha ?? this.notificacionesRacha,
      tamanoFuente: tamanoFuente ?? this.tamanoFuente,
      reproduccionAuto: reproduccionAuto ?? this.reproduccionAuto,
      perfilPublico: perfilPublico ?? this.perfilPublico,
    );
  }
}
