import '../../domain/entities/calificacion.dart';

class CalificacionDto {
  static Calificacion fromJson(Map<String, dynamic> json) {
    return Calificacion(
      idCalificacion: json['id_calificacion'] as int,
      idObjetoFk: json['id_objeto_fk'] as int,
      tipoObjeto: json['tipo_objeto'] as String,
      idUsuarioFk: json['id_usuario_fk'] as int,
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
