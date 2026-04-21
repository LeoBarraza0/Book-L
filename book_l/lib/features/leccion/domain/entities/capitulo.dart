// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_capitulo del modelo relacional.
class Capitulo {
  final int idCapitulo;
  final int idLeccion;
  final String nombre;
  final List<dynamic>? contenido;
  final int tiempoTotal; // duración en segundos

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Capitulo({
    required this.idCapitulo,
    required this.idLeccion,
    required this.nombre,
    this.contenido,
    required this.tiempoTotal,
    this.createdAt,
    this.updatedAt,
  });

  Capitulo copyWith({
    int? idCapitulo,
    int? idLeccion,
    String? nombre,
    List<dynamic>? contenido,
    int? tiempoTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Capitulo(
      idCapitulo: idCapitulo ?? this.idCapitulo,
      idLeccion: idLeccion ?? this.idLeccion,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      tiempoTotal: tiempoTotal ?? this.tiempoTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
