import 'dart:convert';
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
  final String? username;
  final String? descripcion;
  final int? celular;
  final int? semestre;
  final DateTime? nacimiento;
  final String? preferencias;

  const UsuarioDto({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    required this.contrasena,
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

  UsuarioDto copyWith({
    int? idUsuario,
    String? nombreCompleto,
    String? correo,
    String? contrasena,
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
    return UsuarioDto(
      idUsuario: idUsuario ?? this.idUsuario,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
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

  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
        idUsuario: json['id_usuario'] as int,
        nombreCompleto: json['nombre_completo'] as String,
        correo: json['correo'] as String,
        contrasena: json['contrasena'] as String,
        rol: json['rol'] as String,
        programa: json['programa'] as String?,
        activo: json['activo'] as bool,
        avatarUrl: json['avatar_url'] as String?,
        username: json['username'] as String?,
        descripcion: json['descripcion'] as String?,
        celular: json['celular'] as int?,
        semestre: json['semestre'] as int?,
        nacimiento: json['nacimiento'] != null ? DateTime.tryParse(json['nacimiento'] as String) : null,
        preferencias: json['preferencias'] != null ? (json['preferencias'] is String ? json['preferencias'] as String : jsonEncode(json['preferencias'])) : null,
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
        if (username != null) 'username': username,
        if (descripcion != null) 'descripcion': descripcion,
        if (celular != null) 'celular': celular,
        if (semestre != null) 'semestre': semestre,
        if (nacimiento != null) 'nacimiento': nacimiento!.toIso8601String(),
        if (preferencias != null) 'preferencias': preferencias,
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
        username: username,
        descripcion: descripcion,
        celular: celular,
        semestre: semestre,
        nacimiento: nacimiento,
        preferencias: preferencias,
      );
}
