class Notificacion {
  final int id;
  final int idUsuarioFk;
  final String tipo; // e.g. 'follow'
  final int idReferencia; // e.g. id_usuario that followed
  final String mensaje;
  final bool leida;
  final DateTime createdAt;

  const Notificacion({
    required this.id,
    required this.idUsuarioFk,
    required this.tipo,
    required this.idReferencia,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  Notificacion copyWith({
    int? id,
    int? idUsuarioFk,
    String? tipo,
    int? idReferencia,
    String? mensaje,
    bool? leida,
    DateTime? createdAt,
  }) {
    return Notificacion(
      id: id ?? this.id,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      tipo: tipo ?? this.tipo,
      idReferencia: idReferencia ?? this.idReferencia,
      mensaje: mensaje ?? this.mensaje,
      leida: leida ?? this.leida,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
