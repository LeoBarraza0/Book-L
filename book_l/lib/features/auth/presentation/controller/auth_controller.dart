import 'package:flutter/foundation.dart';
import 'dart:math' as dart_math;
import 'dart:convert';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:http/http.dart' as http;

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
        await _sendRealEmail(recoveryEmail!, recoveryCode!);
      } else if (medium == 'Numero') {
        if (recoveryPhone == null || recoveryPhone!.isEmpty) {
          throw Exception(
              'No tienes un número de celular asociado a esta cuenta.');
        }
        await _sendRealSMS(recoveryPhone!, recoveryCode!);
      }
    } catch (e) {
      print('Error al enviar el código de recuperación: $e');
      rethrow; // Propagate error so the UI can catch it and show a SnackBar
    }
  }

  Future<void> _sendRealEmail(String destEmail, String code) async {
    // IMPORTANTE: Reemplaza con tus credenciales reales
    String username = 'tu_correo@gmail.com';
    // Debes generar una "App Password" (Contraseña de aplicación) en tu cuenta de Google
    String password = 'tu_app_password_generada';

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Book-L Soporte')
      ..recipients.add(destEmail)
      ..subject = 'Código de recuperación de contraseña'
      ..text =
          'Hola,\n\nTu código de recuperación para Book-L es: $code\n\nSi no solicitaste esto, ignora este mensaje.'
      ..html =
          '<h3>Recuperación de contraseña</h3><p>Tu código de recuperación para Book-L es: <strong>$code</strong></p>';

    final sendReport = await send(message, smtpServer);
    print('Correo enviado exitosamente: ${sendReport.toString()}');
  }

  Future<void> _sendRealSMS(String destPhone, String code) async {
    // IMPORTANTE: Reemplaza con tus credenciales de Twilio
    String accountSid = 'TU_ACCOUNT_SID_DE_TWILIO';
    String authToken = 'TU_AUTH_TOKEN_DE_TWILIO';
    String twilioNumber = 'TU_NUMERO_DE_TWILIO';

    var bytes = utf8.encode('$accountSid:$authToken');
    var base64Str = base64.encode(bytes);

    var url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic $base64Str',
      },
      body: {
        'From': twilioNumber,
        'To':
            destPhone, // El número debe incluir código de país, ej: +573041234567
        'Body': 'Tu código de recuperación para Book-L es: $code'
      },
    );

    if (response.statusCode == 201) {
      print('SMS enviado exitosamente: ${response.body}');
    } else {
      print('Error al enviar SMS: ${response.body}');
      throw Exception('Fallo al enviar SMS');
    }
  }

  bool validateRecoveryCode(String code) {
    return recoveryCode != null && recoveryCode == code;
  }

  // Temporary list for testing
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
