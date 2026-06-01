import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:book_l/features/usuarios/domain/models/usuarios.dart';
import 'package:book_l/features/usuarios/application/ports/out/usuarios_repository.dart';
import 'package:book_l/features/usuarios/infrastructure/adapters/out/dtos/usuarios_dto.dart';

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
    return List.unmodifiable(list);
  }

  @override
  Future<List<Usuario>> updateUsuario(Usuario usuario) async {
    final list = await _loadFromJson();
    final index = list.indexWhere((u) => u.idUsuario == usuario.idUsuario);
    if (index != -1) {
      list[index] = usuario;
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
