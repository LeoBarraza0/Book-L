// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_curso del modelo relacional.
class Curso {
  final int idCurso;
  final String nombre;
  final String? introduccion;
  final String estado; // 'activo' | 'inactivo' | 'en_revision' | 'suspendido'

  const Curso({
    required this.idCurso,
    required this.nombre,
    this.introduccion,
    required this.estado,
  });

  Curso copyWith({
    int? idCurso,
    String? nombre,
    String? introduccion,
    String? estado,
  }) {
    return Curso(
      idCurso: idCurso ?? this.idCurso,
      nombre: nombre ?? this.nombre,
      introduccion: introduccion ?? this.introduccion,
      estado: estado ?? this.estado,
    );
  }
}
