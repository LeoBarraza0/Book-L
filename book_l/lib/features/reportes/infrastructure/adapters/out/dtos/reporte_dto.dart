import 'package:book_l/features/reportes/domain/models/reporte.dart';

class ReporteDto {
  final int idReporte;
  final int idUsuarioFk;
  final String entidadTipo;
  final int entidadId;
  final String motivo;
  final String createdAt;

  ReporteDto({
    required this.idReporte,
    required this.idUsuarioFk,
    required this.entidadTipo,
    required this.entidadId,
    required this.motivo,
    required this.createdAt,
  });

  factory ReporteDto.fromJson(Map<String, dynamic> json) {
    return ReporteDto(
      idReporte: (json['idreporte'] ?? json['id_reporte']) as int,
      idUsuarioFk: (json['idusuariofk'] ?? json['id_usuario_fk']) as int,
      entidadTipo: json['entidad_tipo'] as String,
      entidadId: json['entidad_id'] as int,
      motivo: json['motivo'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Reporte toEntity() {
    return Reporte(
      idReporte: idReporte,
      idUsuarioFk: idUsuarioFk,
      entidadTipo: entidadTipo,
      entidadId: entidadId,
      motivo: motivo,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
