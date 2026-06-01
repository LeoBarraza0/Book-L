import '../../domain/models/usuarios.dart';
import '../ports/out/usuarios_repository.dart';

/// Caso de uso: obtener lista de usuarios.
class GetUsuariosUseCase {
  final UsuariosRepository repository;

  GetUsuariosUseCase(this.repository);

  Future<List<Usuario>> call() => repository.getUsuarios();
}

/// Caso de uso: añadir un usuario.
class AddUsuarioUseCase {
  final UsuariosRepository repository;

  AddUsuarioUseCase(this.repository);

  Future<List<Usuario>> call(Usuario usuario) => repository.addUsuario(usuario);
}

/// Caso de uso: actualizar un usuario.
class UpdateUsuarioUseCase {
  final UsuariosRepository repository;

  UpdateUsuarioUseCase(this.repository);

  Future<List<Usuario>> call(Usuario usuario) =>
      repository.updateUsuario(usuario);
}

/// Caso de uso: eliminar un usuario por su id.
class DeleteUsuarioUseCase {
  final UsuariosRepository repository;

  DeleteUsuarioUseCase(this.repository);

  Future<List<Usuario>> call(int idUsuario) =>
      repository.deleteUsuario(idUsuario);
}
