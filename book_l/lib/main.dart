import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/infrastructure/services/bookl_service.dart';
import 'core/infrastructure/services/supabase_client.dart';
import 'core/infrastructure/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Supabase con tolerancia a fallos
  try {
    if (SupabaseClientHelper.isConfigured) {
      await Supabase.initialize(
        url: SupabaseClientHelper.url,
        anonKey: SupabaseClientHelper.anonKey,
      );
    } else {
      debugPrint('Supabase: Utilizando credenciales de prueba/mock debido a placeholders.');
    }
  } catch (e) {
    debugPrint('Error al inicializar Supabase: $e');
  }

  await AppSession().init(); // SharedPreferences — sesión del usuario
  await BooklService().init(); // JSON asset / Supabase — datos de negocio
  runApp(const BookLApp());
}

