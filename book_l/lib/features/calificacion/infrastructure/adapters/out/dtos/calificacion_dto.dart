import 'package:book_l/features/calificacion/domain/models/calificacion.dart';

class CalificacionDto {
  static Calificacion fromJson(Map<String, dynamic> json) {
    return Calificacion(
      idCalificacion: (json['idcalificacion'] ?? json['id_calificacion']) as int,
      idObjetoFk: (json['id_objeto_fk'] ?? json['idobjetofk'] ?? 0) as int,
      tipoObjeto: (json['tipo_objeto'] ?? 'leccion') as String,
      idUsuarioFk: (json['idusuariofk'] ?? json['id_usuario_fk']) as int,
      valor: json['valor'] as int,
    );
  }

  static Map<String, dynamic> toJson(Calificacion calificacion) {
    return {
      'id_calificacion': calificacion.idCalificacion,
      'id_objeto_fk': calificacion.idObjetoFk,
      'tipo_objeto': calificacion.tipoObjeto,
      'id_usuario_fk': calificacion.idUsuarioFk,
      'valor': calificacion.valor,
    };
  }
}
