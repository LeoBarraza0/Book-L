import 'package:book_l/features/usuarios/domain/models/usuarios.dart';
import 'package:book_l/features/usuarios/application/ports/out/usuarios_repository.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/auth/infrastructure/adapters/out/dtos/usuario_dto.dart'
    as auth_dto;
import 'package:book_l/features/auth/domain/models/usuario.dart' as auth_model;
import 'package:flutter/foundation.dart';

/// Implementación concreta de [UsuariosRepository].
/// Utiliza BooklService para leer los datos, los cuales ya están
/// sincronizados con Supabase y cacheados en SharedPreferences.
class UsuariosRepositoryImpl implements UsuariosRepository {
  final BooklService _service = BooklService();

  Usuario _mapToDomain(auth_dto.UsuarioDto dto) {
    return Usuario(
      idUsuario: dto.idUsuario,
      nombreCompleto: dto.nombreCompleto,
      correo: dto.correo,
      password: dto.contrasena,
      username: dto.username ?? '',
      celular: dto.celular,
      semestre: dto.semestre,
      nacimiento: dto.nacimiento,
      programa: dto.programa,
      preferencias: dto.preferencias,
      activo: dto.activo,
      rol: dto.rol,
      avatarUrl: dto.avatarUrl,
      descripcion: dto.descripcion,
    );
  }

  @override
  Future<List<Usuario>> getUsuarios() async {
    return _service.usuariosDto.map(_mapToDomain).toList();
  }

  @override
  Future<List<Usuario>> addUsuario(Usuario usuario) async {
    // Añadimos al dto y al modelo de auth para mantener la consistencia en BooklService
    final dto = auth_dto.UsuarioDto(
      idUsuario: usuario.idUsuario,
      nombreCompleto: usuario.nombreCompleto,
      correo: usuario.correo,
      contrasena: usuario.password,
      rol: usuario.rol ?? 'user',
      programa: usuario.programa,
      activo: usuario.activo,
      avatarUrl: usuario.avatarUrl,
      username: usuario.username,
      descripcion: usuario.descripcion,
      celular: usuario.celular,
      semestre: usuario.semestre,
      nacimiento: usuario.nacimiento,
      preferencias: usuario.preferencias,
    );

    _service.usuariosDto.add(dto);
    _service.usuarios.add(dto.toEntity());
    _service.guardarDatos();

    if (SupabaseClientHelper.isConfigured) {
      try {
        final userMap = <String, dynamic>{
          'nombrecompleto': usuario.nombreCompleto,
          'correo': usuario.correo,
          'contrasena': usuario.password,
          'rol': usuario.rol ?? 'user',
          if (usuario.username.isNotEmpty) 'username': usuario.username,
          if (usuario.programa != null) 'programa': usuario.programa,
          if (usuario.celular != null) 'celular': usuario.celular,
          if (usuario.semestre != null) 'semestre': usuario.semestre,
          if (usuario.nacimiento != null)
            'nacimiento': usuario.nacimiento!.toIso8601String().split('T')[0],
          if (usuario.preferencias != null)
            'preferencias': usuario.preferencias,
          if (usuario.avatarUrl != null) 'avatar_url': usuario.avatarUrl,
          if (usuario.descripcion != null) 'descripcion': usuario.descripcion,
          'activo': usuario.activo,
        }..removeWhere((_, v) => v == null);

        await SupabaseClientHelper.client
            .from('tbl_usuario')
            .insert(Map<String, dynamic>.from(userMap));
      } catch (e) {
        if (kDebugMode) {
          print("Error inserting usuario in Supabase: $e");
        }
      }
    }

    return await getUsuarios();
  }

  @override
  Future<List<Usuario>> updateUsuario(Usuario usuario) async {
    // Para actualizar en BooklService, necesitamos convertirlo al modelo de auth
    final authUsuario = auth_model.Usuario(
      idUsuario: usuario.idUsuario,
      nombreCompleto: usuario.nombreCompleto,
      correo: usuario.correo,
      rol: usuario.rol ?? 'user',
      programa: usuario.programa,
      activo: usuario.activo,
      avatarUrl: usuario.avatarUrl,
      username: usuario.username,
      descripcion: usuario.descripcion,
      celular: usuario.celular,
      semestre: usuario.semestre,
      nacimiento: usuario.nacimiento,
      preferencias: usuario.preferencias,
    );

    _service.updateUsuario(authUsuario);
    return await getUsuarios();
  }

  @override
  Future<List<Usuario>> deleteUsuario(int idUsuario) async {
    _service.usuarios.removeWhere((u) => u.idUsuario == idUsuario);
    _service.usuariosDto.removeWhere((u) => u.idUsuario == idUsuario);
    _service.guardarDatos();

    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_usuario')
            .delete()
            .eq('idusuario', idUsuario);
      } catch (e) {
        if (kDebugMode) {
          print("Error deleting usuario in Supabase: $e");
        }
      }
    }

    return await getUsuarios();
  }
}
