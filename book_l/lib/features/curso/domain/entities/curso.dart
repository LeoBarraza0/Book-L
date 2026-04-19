// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_curso del modelo relacional.
class Curso {
  final int idCurso;
  final int idUsuarioFk;
  final String nombre;
  final String? introduccion;
  final String estado; // 'activo' | 'inactivo' | 'en_revision' | 'suspendido'

  const Curso({
    required this.idCurso,
    required this.idUsuarioFk,
    required this.nombre,
    this.introduccion,
    required this.estado,
  });

  Curso copyWith({
    int? idCurso,
    int? idUsuarioFk,
    String? nombre,
    String? introduccion,
    String? estado,
  }) {
    return Curso(
      idCurso: idCurso ?? this.idCurso,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      introduccion: introduccion ?? this.introduccion,
      estado: estado ?? this.estado,
    );
  }
}
