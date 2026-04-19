// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_leccion del modelo relacional.
class Leccion {
  final int idLeccion;
  final int idUsuarioFk;
  final String nombre;
  final List<dynamic>? contenido;
  final String estado; // 'activa' | 'inactiva' | 'en_revision' | 'suspendida'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Leccion({
    required this.idLeccion,
    required this.idUsuarioFk,
    required this.nombre,
    this.contenido,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  Leccion copyWith({
    int? idLeccion,
    int? idUsuarioFk,
    String? nombre,
    List<dynamic>? contenido,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Leccion(
      idLeccion: idLeccion ?? this.idLeccion,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
