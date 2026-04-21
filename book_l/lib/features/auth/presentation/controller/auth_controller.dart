import 'package:flutter/foundation.dart';

import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/auth_usecases.dart';

enum AuthStatus { idle, loading, authenticated, error }

// Adaptador primario — orquesta los use cases y expone el estado a la UI.
class AuthController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal() {
    final repo = AuthRepositoryImpl(BooklService(), AppSession());
    _login = LoginUseCase(repo);
    _register = RegisterUseCase(repo);
    _logout = LogoutUseCase(repo);
  }

  late final LoginUseCase _login;
  late final RegisterUseCase _register;
  late final LogoutUseCase _logout;

  AuthStatus status = AuthStatus.idle;
  Usuario? usuarioActual;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<bool> iniciarSesion(String correo, String contrasena) async {
    _setLoading();
    try {
      final usuario = await _login(correo, contrasena);
      if (usuario == null) {
        _setError('Correo o contraseña incorrectos');
        return false;
      }
      usuarioActual = usuario;
      BooklService().setRole(usuario.rol);
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Registro ───────────────────────────────────────────────────────────────
  Future<bool> registrar({
    required String nombreCompleto,
    required String correo,
    required String contrasena,
    required String rol,
    String? programa,
  }) async {
    _setLoading();
    try {
      final usuario = await _register(
        nombreCompleto: nombreCompleto,
        correo: correo,
        contrasena: contrasena,
        rol: rol,
        programa: programa,
      );
      usuarioActual = usuario;
      BooklService().setRole(usuario.rol);
      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _logout();
    usuarioActual = null;
    status = AuthStatus.idle;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    status = AuthStatus.error;
    errorMessage = msg;
    notifyListeners();
  }

  void clearError() {
    if (status == AuthStatus.error) {
      status = AuthStatus.idle;
      errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Es un Singleton, no debe destruirse nunca para evitar errores de 'used after being disposed'.
  }
}
