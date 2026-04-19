class Usuario {
  final int idUsuario;
  final String nombreCompleto;
  final String correo;
  final String password;
  final String username;
  final int? celular;
  final int? semestre;
  final DateTime? nacimiento;
  final String? programa;
  final String? preferencias; 
  final bool activo;
  final String? rol;
  final String? avatarUrl; // Extra field for UI

  Usuario({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.password,
    required this.username,
    this.celular,
    this.semestre,
    this.nacimiento,
    this.programa,
    this.preferencias,
    this.activo = true,
    this.rol,
    this.avatarUrl,
  });

  // Factory constructor for creating a Usuario from JSON could be added later in a DTO
  // but for now we keep the entity clean as per the architecture.
}
