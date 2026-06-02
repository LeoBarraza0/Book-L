import 'package:book_l/features/notificacion/domain/models/notificacion.dart';

class NotificacionDto {
  final int id;
  final int idUsuarioFk;
  final String tipo;
  final int idReferencia;
  final String mensaje;
  final bool leida;
  final String createdAt;

  NotificacionDto({
    required this.id,
    required this.idUsuarioFk,
    required this.tipo,
    required this.idReferencia,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  factory NotificacionDto.fromJson(Map<String, dynamic> json) {
    return NotificacionDto(
      id: (json['idnotificacion'] ?? json['id']) as int,
      idUsuarioFk: (json['idusuariofk'] ?? json['id_usuario_fk']) as int,
      tipo: json['tipo'] as String,
      idReferencia: (json['idreferencia'] ?? json['id_referencia']) as int,
      mensaje: json['mensaje'] as String,
      leida: json['leida'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  Notificacion toEntity() {
    return Notificacion(
      id: id,
      idUsuarioFk: idUsuarioFk,
      tipo: tipo,
      idReferencia: idReferencia,
      mensaje: mensaje,
      leida: leida,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idnotificacion': id,
      'idusuariofk': idUsuarioFk,
      'tipo': tipo,
      'idreferencia': idReferencia,
      'mensaje': mensaje,
      'leida': leida,
      'created_at': createdAt,
    };
  }
}
