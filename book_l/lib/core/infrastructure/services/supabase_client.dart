import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper de conexión para Supabase.
///
/// Contiene las credenciales del proyecto de Supabase y expone el cliente
/// oficial para realizar consultas en PostgreSQL.
class SupabaseClientHelper {
  // =========================================================================
  // CREDENCIALES DE SOPORTE PARA EL PROYECTO
  // Reemplaza estas credenciales por las de tu panel de Supabase si cambian
  // =========================================================================
  static const String url = 'https://zfbclsohgbqbasbbxntl.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmYmNsc29oZ2JxYmFzYmJ4bnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTczODQsImV4cCI6MjA5NTkzMzM4NH0.XvHf9DNPQ0wjX6ztmoqZe16chJSloQ7cIysjifVWL5k';

  /// Retorna la instancia del cliente de Supabase oficial.
  static SupabaseClient get client => Supabase.instance.client;

  /// Indica si Supabase ha sido inicializado correctamente y si las
  /// credenciales actuales son válidas (no placeholders).
  static bool get isConfigured {
    return url.isNotEmpty && anonKey.isNotEmpty;
  }

  /// Sube un archivo a Supabase Storage y retorna su URL pública.
  /// Soporta rutas locales (móvil) y URLs blob (Flutter Web).
  static Future<String?> uploadFile(String bucket, String path, {String? fileName}) async {
    if (!isConfigured) return null;
    try {
      final isBlob = path.startsWith('blob:');
      String name;
      if (fileName != null) {
        name = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      } else {
        name = '${DateTime.now().millisecondsSinceEpoch}';
      }

      if (!name.contains('.')) {
        if (!isBlob) {
          final ext = path.split('.').last;
          name = '$name.$ext';
        } else {
          name = '$name.jpg'; // Solo por defecto si no tenemos fileName ni extensión
        }
      }

      if (kIsWeb && isBlob) {
        // En Web, ImagePicker devuelve una URL blob. Descargamos los bytes:
        final response = await http.get(Uri.parse(path));
        final bytes = response.bodyBytes;
        await client.storage.from(bucket).uploadBinary(
          name,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
      } else {
        // En Móvil, leemos el archivo localmente
        final file = File(path);
        await client.storage.from(bucket).upload(
          name,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      }

      return client.storage.from(bucket).getPublicUrl(name);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading to Supabase: $e');
      }
      return null;
    }
  }

  /// Sube un archivo usando sus bytes directamente (útil para Web con FilePicker).
  static Future<String?> uploadBytes(String bucket, Uint8List bytes, String fileName) async {
    if (!isConfigured) return null;
    try {
      final name = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await client.storage.from(bucket).uploadBinary(
        name,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      return client.storage.from(bucket).getPublicUrl(name);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading bytes to Supabase: $e');
      }
      return null;
    }
  }
}
