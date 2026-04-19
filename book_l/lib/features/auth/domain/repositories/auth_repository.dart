import '../entities/usuario.dart';

// Puerto de salida (Outbound Port) — contrato de autenticación.
// La implementación vive en data/repositories/auth_repository_impl.dart.
abstract class AuthRepository {
  /// Valida credenciales. Devuelve el [Usuario] autenticado o null si no coincide.
  Future<Usuario?> login(String correo, String contrasena);

  /// Registra un nuevo usuario. Lanza excepción si el correo ya existe.
  Future<Usuario> registrar({
    required String nombreCompleto,
    required String correo,
    required String contrasena,
    required String rol,
    String? programa,
  });

  /// Cierra sesión — limpia AppSession.
  Future<void> logout();
}
