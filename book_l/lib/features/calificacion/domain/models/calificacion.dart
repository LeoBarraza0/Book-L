// Entidad pura de dominio — sin imports de Flutter
class Calificacion {
  final int idCalificacion;
  final int idObjetoFk;
  final String tipoObjeto; // 'leccion' | 'curso'
  final int idUsuarioFk;
  final int valor; // 1 a 5

  const Calificacion({
    required this.idCalificacion,
    required this.idObjetoFk,
    required this.tipoObjeto,
    required this.idUsuarioFk,
    required this.valor,
  });

  Calificacion copyWith({
    int? idCalificacion,
    int? idObjetoFk,
    String? tipoObjeto,
    int? idUsuarioFk,
    int? valor,
  }) {
    return Calificacion(
      idCalificacion: idCalificacion ?? this.idCalificacion,
      idObjetoFk: idObjetoFk ?? this.idObjetoFk,
      tipoObjeto: tipoObjeto ?? this.tipoObjeto,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      valor: valor ?? this.valor,
    );
  }
}
