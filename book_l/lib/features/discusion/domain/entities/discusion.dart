class Discusion {
  final int idDiscusion;
  final int? idCursoFk;
  final int? idLeccionFk;

  const Discusion({
    required this.idDiscusion,
    this.idCursoFk,
    this.idLeccionFk,
  });
}
