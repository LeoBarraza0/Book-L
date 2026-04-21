import 'comentario.dart';

class Discusion {
  final int idDiscusion;
  final int? idCursoFk;
  final int? idLeccionFk;
  final List<Comentario> comentarios; // Agregado para mapeo relacional

  const Discusion({
    required this.idDiscusion,
    this.idCursoFk,
    this.idLeccionFk,
    this.comentarios = const [],
  });

  Discusion copyWith({
    int? idDiscusion,
    int? idCursoFk,
    int? idLeccionFk,
    List<Comentario>? comentarios,
  }) {
    return Discusion(
      idDiscusion: idDiscusion ?? this.idDiscusion,
      idCursoFk: idCursoFk ?? this.idCursoFk,
      idLeccionFk: idLeccionFk ?? this.idLeccionFk,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}
