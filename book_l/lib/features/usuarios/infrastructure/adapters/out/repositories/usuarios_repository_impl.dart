import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:book_l/features/usuarios/domain/models/usuarios.dart';
import 'package:book_l/features/usuarios/application/ports/out/usuarios_repository.dart';
import 'package:book_l/features/usuarios/infrastructure/adapters/out/dtos/usuarios_dto.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:flutter/foundation.dart';

/// Implementación concreta de [UsuariosRepository].
///
/// Fase actual: lee y mantiene los datos desde el archivo JSON local
/// (assets/data/bookl_data.json). Las operaciones de escritura (add,
/// update, delete) se aplican sobre una lista en memoria.
///
/// Migración futura: reemplazar el cuerpo de cada método por llamadas
/// a la API REST sin tocar el resto de las capas.
class UsuariosRepositoryImpl implements UsuariosRepository {
  /// Lista en memoria que actúa como "base de datos" temporal.
  /// Es estática para que los cambios persistan entre navegaciones
  /// (mientras la app esté viva). Se reemplaza por una llamada a la
  /// API cuando se integre el backend.
  static List<Usuario>? _cache;

  /// Carga los usuarios desde el JSON la primera vez y los cachea.
  Future<List<Usuario>> _loadFromJson() async {
    if (_cache != null) return _cache!;

    final jsonString =
        await rootBundle.loadString('assets/data/bookl_data.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> usuariosJson = data['usuarios'] as List<dynamic>;

    _cache = usuariosJson
        .map((e) => UsuarioDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cache!;
  }

  @override
  Future<List<Usuario>> getUsuarios() async {
    return List.unmodifiable(await _loadFromJson());
  }

  @override
  Future<List<Usuario>> addUsuario(Usuario usuario) async {
    final list = await _loadFromJson();
    list.add(usuario);

    if (SupabaseClientHelper.isConfigured) {
      try {
        final userMap = <String, dynamic>{
          'nombrecompleto': usuario.nombreCompleto,
          'correo': usuario.correo,
          'contrasena': usuario.password ??
              '12345678', // Password fallback since it might not be in the model
          'rol': usuario.rol,
          if (usuario.username != null) 'username': usuario.username,
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

    return List.unmodifiable(list);
  }

  @override
  Future<List<Usuario>> updateUsuario(Usuario usuario) async {
    final list = await _loadFromJson();
    final index = list.indexWhere((u) => u.idUsuario == usuario.idUsuario);
    if (index != -1) {
      list[index] = usuario;
    }

    if (SupabaseClientHelper.isConfigured) {
      try {
        final userMap = <String, dynamic>{
          'nombrecompleto': usuario.nombreCompleto,
          'correo': usuario.correo,
          'rol': usuario.rol,
          if (usuario.username != null) 'username': usuario.username,
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
            .update(Map<String, dynamic>.from(userMap))
            .eq('idusuario', usuario.idUsuario);
      } catch (e) {
        if (kDebugMode) {
          print("Error updating usuario in Supabase: $e");
        }
      }
    }

    return List.unmodifiable(list);
  }

  @override
  Future<List<Usuario>> deleteUsuario(int idUsuario) async {
    final list = await _loadFromJson();
    list.removeWhere((u) => u.idUsuario == idUsuario);
    return List.unmodifiable(list);
  }
}