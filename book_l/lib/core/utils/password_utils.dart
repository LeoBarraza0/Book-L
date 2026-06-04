import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordUtils {
  /// Devuelve el hash SHA-256 de una contraseña en texto plano
  static String hashPassword(String plainPassword) {
    final bytes = utf8.encode(plainPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
