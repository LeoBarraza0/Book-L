import '../entities/usuarios.dart';

/// Interfaz (puerto de salida) del dominio de usuarios.
/// Implementada en data/repositories/usuarios_repository_impl.dart
/// Actualmente lee del JSON local; cuando haya API se reemplaza solo la impl.
abstract class UsuariosRepository {
  /// Devuelve la lista completa de usuarios.
  Future<List<Usuario>> getUsuarios();

  /// Añade un nuevo usuario y devuelve la lista actualizada.
  Future<List<Usuario>> addUsuario(Usuario usuario);

  /// Actualiza un usuario existente y devuelve la lista actualizada.
  Future<List<Usuario>> updateUsuario(Usuario usuario);

  /// Elimina el usuario con [idUsuario] y devuelve la lista actualizada.
  Future<List<Usuario>> deleteUsuario(int idUsuario);
}
