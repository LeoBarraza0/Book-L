class Comentario {
  final int idComentario;
  final int idDiscusionFk;
  final int idUsuarioFk;
  final String contenido;
  final int? idPadre;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Comentario({
    required this.idComentario,
    required this.idDiscusionFk,
    required this.idUsuarioFk,
    required this.contenido,
    this.idPadre,
    required this.createdAt,
    this.updatedAt,
  });
}
