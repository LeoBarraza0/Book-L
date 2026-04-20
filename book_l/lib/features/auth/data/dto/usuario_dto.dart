import '../../domain/entities/usuario.dart';

// DTO del adaptador secundario — único lugar donde vive la contraseña en memoria.
// La contraseña NUNCA sube a domain/ ni a presentation/.
class UsuarioDto {
  final int idUsuario;
  final String nombreCompleto;
  final String correo;
  final String contrasena; // texto plano — solo para JSON local
  final String rol;
  final String? programa;
  final bool activo;
  final String? avatarUrl;

  const UsuarioDto({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.contrasena,
    required this.rol,
    this.programa,
    required this.activo,
    this.avatarUrl,
  });

  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
        idUsuario: json['id_usuario'] as int,
        nombreCompleto: json['nombre_completo'] as String,
        correo: json['correo'] as String,
        contrasena: json['contrasena'] as String,
        rol: json['rol'] as String,
        programa: json['programa'] as String?,
        activo: json['activo'] as bool,
        avatarUrl: json['avatar_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'nombre_completo': nombreCompleto,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol,
        if (programa != null) 'programa': programa,
        'activo': activo,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  /// Convierte al entity de dominio (sin contraseña).
  Usuario toEntity() => Usuario(
        idUsuario: idUsuario,
        nombreCompleto: nombreCompleto,
        correo: correo,
        rol: rol,
        programa: programa,
        activo: activo,
        avatarUrl: avatarUrl,
      );
}
