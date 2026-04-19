import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

// ── LoginUseCase ─────────────────────────────────────────────────────────────
class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  /// Devuelve [Usuario] en éxito o null si las credenciales son incorrectas.
  Future<Usuario?> call(String correo, String contrasena) =>
      _repo.login(correo, contrasena);
}

// ── RegisterUseCase ──────────────────────────────────────────────────────────
class RegisterUseCase {
  final AuthRepository _repo;
  RegisterUseCase(this._repo);

  Future<Usuario> call({
    required String nombreCompleto,
    required String correo,
    required String contrasena,
    required String rol,
    String? programa,
  }) =>
      _repo.registrar(
        nombreCompleto: nombreCompleto,
        correo: correo,
        contrasena: contrasena,
        rol: rol,
        programa: programa,
      );
}

// ── LogoutUseCase ─────────────────────────────────────────────────────────────
class LogoutUseCase {
  final AuthRepository _repo;
  LogoutUseCase(this._repo);

  Future<void> call() => _repo.logout();
}
