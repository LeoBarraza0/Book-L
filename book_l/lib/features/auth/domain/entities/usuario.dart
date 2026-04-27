// Entidad pura de dominio — sin imports de Flutter ni paquetes externos.
// Corresponde a Tbl_usuario del modelo relacional.
// La contraseña NUNCA viaja en esta entidad (se maneja solo en el DTO y el repositorio).
class Usuario {
  final int idUsuario;
  final String nombreCompleto;
  final String correo;
  final String rol; // 'Estudiante' | 'Profesor' | 'Administrador'
  final String? programa;
  final bool activo;
  final String? avatarUrl;
  final String? username;
  final String? descripcion;
  final int? celular;
  final int? semestre;
  final DateTime? nacimiento;
  final String? preferencias;

  const Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
    this.programa,
    required this.activo,
    this.avatarUrl,
    this.username,
    this.descripcion,
    this.celular,
    this.semestre,
    this.nacimiento,
    this.preferencias,
  });

  Usuario copyWith({
    int? idUsuario,
    String? nombreCompleto,
    String? correo,
    String? rol,
    String? programa,
    bool? activo,
    String? avatarUrl,
    String? username,
    String? descripcion,
    int? celular,
    int? semestre,
    DateTime? nacimiento,
    String? preferencias,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      programa: programa ?? this.programa,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      descripcion: descripcion ?? this.descripcion,
      celular: celular ?? this.celular,
      semestre: semestre ?? this.semestre,
      nacimiento: nacimiento ?? this.nacimiento,
      preferencias: preferencias ?? this.preferencias,
    );
  }
}
