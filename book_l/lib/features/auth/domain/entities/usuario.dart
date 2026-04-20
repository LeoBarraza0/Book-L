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

  const Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.rol,
    this.programa,
    required this.activo,
    this.avatarUrl,
  });

  Usuario copyWith({
    int? idUsuario,
    String? nombreCompleto,
    String? correo,
    String? rol,
    String? programa,
    bool? activo,
    String? avatarUrl,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      programa: programa ?? this.programa,
      activo: activo ?? this.activo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
