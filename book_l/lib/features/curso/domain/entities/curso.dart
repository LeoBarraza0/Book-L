// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_curso del modelo relacional.
class Curso {
  final int idCurso;
  final int idUsuarioFk;
  final String nombre;
  final List<dynamic>? contenido;
  final String estado; // 'activo' | 'inactivo' | 'en_revision' | 'suspendido'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Curso({
    required this.idCurso,
    required this.idUsuarioFk,
    required this.nombre,
    this.contenido,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  Curso copyWith({
    int? idCurso,
    int? idUsuarioFk,
    String? nombre,
    List<dynamic>? contenido,
    String? estado,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Curso(
      idCurso: idCurso ?? this.idCurso,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
