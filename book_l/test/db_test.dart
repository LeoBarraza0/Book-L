import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Registration and Password Validation Tests', () {
    test('Email format validation regex test', () {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      
      expect(emailRegex.hasMatch('valid@gmail.com'), isTrue);
      expect(emailRegex.hasMatch('valid.name@domain.co.uk'), isTrue);
      expect(emailRegex.hasMatch('invalidemail'), isFalse);
      expect(emailRegex.hasMatch('invalid@'), isFalse);
      expect(emailRegex.hasMatch('invalid@domain'), isFalse);
    });

    test('Password complexity rule test', () {
      bool validatePassword(String pass) {
        final hasEightChars = pass.length >= 8;
        final hasUppercase = pass.contains(RegExp(r'[A-Z]'));
        final hasSpecialChar = pass.contains(RegExp(r'[^a-zA-Z0-9\s]'));

        if (!hasEightChars) return false;
        if (!hasUppercase && !hasSpecialChar) return false;
        return true;
      }

      // Valid cases (8+ chars AND (uppercase OR special))
      expect(validatePassword('Password123'), isTrue);      // 8+ chars and uppercase
      expect(validatePassword('password#123'), isTrue);     // 8+ chars and special
      expect(validatePassword('Pass#123'), isTrue);         // 8+ chars, uppercase, and special

      // Invalid cases
      expect(validatePassword('pass123'), isFalse);         // Too short (< 8 chars)
      expect(validatePassword('Pass#'), isFalse);           // Too short (< 8 chars)
      expect(validatePassword('password123'), isFalse);     // 8+ chars but no uppercase and no special
    });

    test('Real database insert of user with program and preferences', () async {
      const url = 'https://zfbclsohgbqbasbbxntl.supabase.co/rest/v1/tbl_usuario';
      const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmYmNsc29oZ2JxYmFzYmJ4bnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTczODQsImV4cCI6MjA5NTkzMzM4NH0.XvHf9DNPQ0wjX6ztmoqZe16chJSloQ7cIysjifVWL5k';
      
      final String uniqueEmail = 'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final String uniqueUsername = 'testuser_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      final payload = {
        'nombrecompleto': 'Test Verification User',
        'correo': uniqueEmail,
        'contrasena': 'SecurePassword#2026',
        'username': uniqueUsername,
        'rol': 'Estudiante',
        'programa': 'Psicología', // Program from pg type list
        'semestre': 4,
        'nacimiento': '2001-05-15',
        'preferencias': {
          'intereses': ['Flutter', 'Pruebas', 'Dart']
        },
        'activo': true,
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'apikey': anonKey,
            'Authorization': 'Bearer $anonKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=representation',
          },
          body: jsonEncode(payload),
        );
        
        expect(response.statusCode, equals(201)); // Created
        final List<dynamic> res = jsonDecode(response.body);
        expect(res.isNotEmpty, isTrue);
        
        final createdUser = res.first;
        expect(createdUser['nombrecompleto'], equals('Test Verification User'));
        expect(createdUser['programa'], equals('Psicología'));
        expect(createdUser['semestre'], equals(4));
        expect(createdUser['nacimiento'], equals('2001-05-15'));
        
        // Clean up the created test user so we don't bloat the database
        final deleteUrl = '$url?idusuario=eq.${createdUser['idusuario']}';
        final deleteResponse = await http.delete(
          Uri.parse(deleteUrl),
          headers: {
            'apikey': anonKey,
            'Authorization': 'Bearer $anonKey',
          },
        );
        expect(deleteResponse.statusCode, isIn([200, 204]));
        print('DB insert and preferences formatting verified successfully!');
      } catch (e) {
        fail('Database test failed with error: $e');
      }
    });
  });
}
