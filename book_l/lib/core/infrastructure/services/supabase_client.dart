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
  static const String url = 'https://zfbclsohgbqbasbbxntl.supabase.co/rest/v1/';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmYmNsc29oZ2JxYmFzYmJ4bnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTczODQsImV4cCI6MjA5NTkzMzM4NH0.XvHf9DNPQ0wjX6ztmoqZe16chJSloQ7cIysjifVWL5k';

  /// Retorna la instancia del cliente de Supabase oficial.
  static SupabaseClient get client => Supabase.instance.client;

  /// Indica si Supabase ha sido inicializado correctamente y si las
  /// credenciales actuales son válidas (no placeholders).
  static bool get isConfigured {
    return url != 'https://zfbclsohgbqbasbbxntl.supabase.co/rest/v1/' &&
        anonKey !=
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpmYmNsc29oZ2JxYmFzYmJ4bnRsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzNTczODQsImV4cCI6MjA5NTkzMzM4NH0.XvHf9DNPQ0wjX6ztmoqZe16chJSloQ7cIysjifVWL5k';
  }
}
