import 'dart:convert';
import '../../domain/entities/usuarios.dart';

/// DTO para mapear un objeto JSON del archivo bookl_data.json
/// a la entidad de dominio [Usuario].
///
/// Regla arquitectural: este es el ÚNICO archivo que
/// puede usar fromJson / toJson en la feature usuarios.
class UsuarioDto {
  static Usuario fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['id_usuario'] as int,
      nombreCompleto: json['nombre_completo'] as String,
      correo: json['correo'] as String,
      password: (json['contrasena'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      celular: json['celular'] != null ? json['celular'] as int : null,
      semestre: json['semestre'] != null ? json['semestre'] as int : null,
      nacimiento: json['nacimiento'] != null
          ? DateTime.tryParse(json['nacimiento'] as String)
          : null,
      programa: json['programa'] as String?,
      preferencias: json['preferencias'] != null 
          ? (json['preferencias'] is String ? json['preferencias'] as String : jsonEncode(json['preferencias'])) 
          : null,
      activo: (json['activo'] as bool?) ?? true,
      rol: json['rol'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  static Map<String, dynamic> toJson(Usuario u) {
    return {
      'id_usuario': u.idUsuario,
      'nombre_completo': u.nombreCompleto,
      'correo': u.correo,
      'contrasena': u.password,
      'username': u.username,
      if (u.celular != null) 'celular': u.celular,
      if (u.semestre != null) 'semestre': u.semestre,
      if (u.nacimiento != null)
        'nacimiento': u.nacimiento!.toIso8601String(),
      if (u.programa != null) 'programa': u.programa,
      if (u.preferencias != null) 'preferencias': u.preferencias,
      'activo': u.activo,
      if (u.rol != null) 'rol': u.rol,
      if (u.avatarUrl != null) 'avatar_url': u.avatarUrl,
    };
  }
}
