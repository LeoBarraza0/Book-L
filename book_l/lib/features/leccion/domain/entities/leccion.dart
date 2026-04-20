// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_leccion del modelo relacional.
class Leccion {
  final int idLeccion;
  final int idUsuarioFk;
  final String nombre;
  final List<dynamic>? contenido;
  final double rating;
  final String duracion;
  final int estudiantes;
  final double progreso;
  final int? tagColor;
  final bool esNuevo;
  final String estado; // 'activa' | 'inactiva' | 'en_revision' | 'suspendida'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Leccion({
    required this.idLeccion,
    required this.idUsuarioFk,
    required this.nombre,
    this.contenido,
    this.rating = 0.0,
    this.duracion = '',
    this.estudiantes = 0,
    this.progreso = 0.0,
    this.tagColor,
    this.esNuevo = true,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  Leccion copyWith({
    int? idLeccion,
    int? idUsuarioFk,
    String? nombre,
    List<dynamic>? contenido,
    double? rating,
    String? duracion,
    int? estudiantes,
    double? progreso,
    int? tagColor,
    bool? esNuevo,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Leccion(
      idLeccion: idLeccion ?? this.idLeccion,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      rating: rating ?? this.rating,
      duracion: duracion ?? this.duracion,
      estudiantes: estudiantes ?? this.estudiantes,
      progreso: progreso ?? this.progreso,
      tagColor: tagColor ?? this.tagColor,
      esNuevo: esNuevo ?? this.esNuevo,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
