import 'package:flutter/foundation.dart';
import 'dart:math' as dart_math;
import 'dart:convert';

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

  // Recovery data
  String? recoveryEmail;
  String? recoveryPhone;
  String? recoveryCode;

  void setRecoveryData(String email, String phone) {
    recoveryEmail = email;
    if (phone.isNotEmpty) {
      recoveryPhone = phone.startsWith('+') ? phone : '+57$phone';
    } else {
      recoveryPhone = null;
    }
    notifyListeners();
  }

  Future<void> generateRecoveryCode(String medium) async {
    final random = dart_math.Random();
    recoveryCode = (100000 + random.nextInt(900000)).toString();
    notifyListeners();

    try {
      if (medium == 'Correo') {
        if (recoveryEmail == null || recoveryEmail!.isEmpty) {
          throw Exception(
              'No tienes un correo registrado asociado a esta cuenta.');
        }
        print('=====================================================');
        print('CÓDIGO DE RECUPERACIÓN (CORREO): $recoveryCode');
        print('=====================================================');
      } else if (medium == 'Numero') {
        if (recoveryPhone == null || recoveryPhone!.isEmpty) {
          throw Exception(
              'No tienes un número de celular asociado a esta cuenta.');
        }
        print('=====================================================');
        print('CÓDIGO DE RECUPERACIÓN (SMS): $recoveryCode');
        print('=====================================================');
      }
    } catch (e) {
      print('Error al generar el código de recuperación: $e');
      rethrow;
    }
  }

  Future<bool> restablecerPassword(String nuevaPassword) async {
    final svc = BooklService();
    try {
      int index = -1;
      if (recoveryEmail != null && recoveryEmail!.isNotEmpty) {
        index = svc.usuariosDto.indexWhere((u) => u.correo == recoveryEmail);
      } else if (recoveryPhone != null && recoveryPhone!.isNotEmpty) {
        index = svc.usuariosDto.indexWhere((u) =>
            u.celular?.toString() == recoveryPhone ||
            '+57${u.celular}' == recoveryPhone);
      }

      if (index != -1) {
        final usuario = svc.usuariosDto[index];
        svc.usuariosDto[index] = usuario.copyWith(contrasena: nuevaPassword);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al restablecer contraseña: $e');
      return false;
    }
  }

  bool validateRecoveryCode(String code) {
    return recoveryCode != null && recoveryCode == code;
  }

  List<Map<String, dynamic>> recoveryAttempts = [];

  void saveRecoveryAttempt(String type) {
    if (recoveryEmail != null) {
      recoveryAttempts.add({
        'email': recoveryEmail,
        'type': type,
        'timestamp': DateTime.now().toString(),
      });
      print('Recovery Attempt Saved: $recoveryAttempts');
    }
    notifyListeners();
  }

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
