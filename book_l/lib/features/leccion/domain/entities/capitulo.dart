// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_capitulo del modelo relacional.
class Capitulo {
  final int idCapitulo;
  final int idLeccion;
  final String nombre;
  final String? introduccion;
  final int tiempoTotal; // duración en segundos

  const Capitulo({
    required this.idCapitulo,
    required this.idLeccion,
    required this.nombre,
    this.introduccion,
    required this.tiempoTotal,
  });

  Capitulo copyWith({
    int? idCapitulo,
    int? idLeccion,
    String? nombre,
    String? introduccion,
    int? tiempoTotal,
  }) {
    return Capitulo(
      idCapitulo: idCapitulo ?? this.idCapitulo,
      idLeccion: idLeccion ?? this.idLeccion,
      nombre: nombre ?? this.nombre,
      introduccion: introduccion ?? this.introduccion,
      tiempoTotal: tiempoTotal ?? this.tiempoTotal,
    );
  }
}
