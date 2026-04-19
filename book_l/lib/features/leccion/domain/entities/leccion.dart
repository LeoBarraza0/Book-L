// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_leccion del modelo relacional.
class Leccion {
  final int idLeccion;
  final int idUsuarioFk;
  final String nombre;
  final String? introduccion;
  final String estado; // 'activa' | 'inactiva' | 'en_revision' | 'suspendida'

  const Leccion({
    required this.idLeccion,
    required this.idUsuarioFk,
    required this.nombre,
    this.introduccion,
    required this.estado,
  });

  Leccion copyWith({
    int? idLeccion,
    int? idUsuarioFk,
    String? nombre,
    String? introduccion,
    String? estado,
  }) {
    return Leccion(
      idLeccion: idLeccion ?? this.idLeccion,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      introduccion: introduccion ?? this.introduccion,
      estado: estado ?? this.estado,
    );
  }
}
