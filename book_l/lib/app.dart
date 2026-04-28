import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/notificacion/presentation/screens/notificaciones_screen.dart';
import 'features/perfil/presentation/screens/perfil_screen.dart';
import 'features/configuracion/presentation/screens/sugerencia_screen.dart';
import 'features/configuracion/presentation/screens/configuracion_screen.dart';
import 'features/chatbot/presentation/screens/chatbot_screen.dart';
import 'features/curso/presentation/screens/curso_detail_screen.dart';
import 'features/leccion/presentation/screens/leccion_detail_screen.dart';
import 'features/leccion/presentation/screens/capitulo_screen.dart';
import 'features/busqueda/presentation/screens/busqueda_screen.dart';
import 'features/busqueda/presentation/screens/resultado_screen.dart';
import 'features/ejercicio/presentation/screens/teorico_screen.dart';
import 'features/calificacion/presentation/screens/resultado_screen.dart';
import 'features/curso/presentation/screens/publicar_curso_screen.dart';
import 'features/leccion/presentation/screens/publicar_leccion_screen.dart';

import 'features/ejercicio/domain/entities/ejercicio.dart';
import 'features/home/presentation/screens/admin_home_screen.dart';
import 'features/leccion/presentation/screens/admin_leccion_screen.dart';
import 'features/curso/presentation/screens/curso_editar_screen.dart';
import 'features/leccion/presentation/screens/leccion_editar_screen.dart';
import 'features/leccion/presentation/screens/capitulo_editar_screen.dart';
import 'features/leccion/presentation/screens/crear_capitulo_screen.dart';
import 'features/usuarios/presentation/screens/usuarios_screen.dart';
import 'features/reportes/presentation/screens/reportes_screen.dart';
import 'features/reportes/presentation/screens/reporte_detail_screen.dart';

import 'features/perfil/presentation/screens/usuario_perfil_screen.dart';
import 'features/onboarding/presentation/screens/bienvenida_screen.dart';
import 'features/auth/presentation/screens/recuperar_correo_screen.dart';
import 'features/auth/presentation/screens/recuperar_numero_screen.dart';
import 'features/auth/presentation/screens/ingresar_codigo_screen.dart';
import 'features/auth/presentation/screens/cambiar_password_screen.dart';

import 'core/storage/local_storage.dart';

class BookLApp extends StatelessWidget {
  const BookLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSession().temaNotifier,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppSession().fontScaleNotifier,
          builder: (context, fontScale, _) {
            double textScaleFactor = 1.0;
            if (fontScale == 'pequeno') textScaleFactor = 0.85;
            if (fontScale == 'grande') textScaleFactor = 1.25;

            return MaterialApp(
              title: 'Book-L',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'),
                Locale('en'),
                Locale('es', 'ES'),
                Locale('es'),
              ],
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              theme: ThemeData(
                fontFamily: 'Inter',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4DC130),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Inter',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4DC130),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
              ),
              builder: (context, child) {
                // Apply global font scaling
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScaleFactor),
                  ),
                  child: child!,
                );
              },
              initialRoute: !AppSession().onboardingCompleted
                  ? '/bienvenida'
                  : (AppSession().estaLogueado 
                      ? (AppSession().esAdministrador ? '/admin_Home' : '/home') 
                      : '/login'),
              routes: {
                '/bienvenida': (context) => const BienvenidaScreen(),
                '/login': (context) => const LoginScreen(),
                '/recuperar_correo': (context) => const RecuperarCorreoScreen(),
                '/recuperar_numero': (context) => const RecuperarNumeroScreen(),
                '/ingresar_codigo': (context) => const IngresarCodigoScreen(),
                '/cambiar_password': (context) => const CambiarPasswordScreen(),
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/notificaciones': (context) => const NotificacionScreen(),
                '/perfil': (context) => const PerfilScreen(),
                '/configuracion': (context) => const ConfiguracionScreen(),
                '/sugerencia': (context) => const SugerenciaScreen(),
                '/chatbot': (context) => const ChatbotScreen(),
                '/curso_detail': (context) => CursoDetailScreen(
                      idCurso: ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/leccion_detail': (context) => LeccionDetailScreen(
                      idLeccion: ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/editar_capitulo': (context) => CapituloEditarScreen(
                      idCapitulo: ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/capitulo_detail': (context) => CapituloScreen(
                      idCapitulo: ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/busqueda': (context) => const BusquedaScreen(),
                '/resultado': (context) => const ResultadoScreen(),
                '/teorico': (context) => TeoricoScreen(
                      ejercicio: ModalRoute.of(context)?.settings.arguments as Ejercicio,
                    ),
                // '/calificacion': (context) => const EjercicioResultadoScreen(),
                '/publicar_curso': (context) => const PublicarCursoScreen(),
                '/publicar_leccion': (context) => const PublicarLeccionScreen(),

                '/admin_Home': (context) => const AdminHomeScreen(),
                '/admin_leccion': (context) => const AdminLeccionScreen(),
                '/editar_curso': (context) => const CursoEditarScreen(),
                '/editar_leccion': (context) => LeccionEditarScreen(
                      idLeccion: ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/users_admin': (context) => const UsuariosScreen(),
                '/crear_capitulo': (context) => const CrearCapituloScreen(),
                '/reportes': (context) => const ReportesScreen(),
                '/reporte_detail': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                  return ReporteDetailScreen(
                    idLeccion: args?['id_leccion'] as int? ?? 0,
                    leccionNombre: args?['nombre'] as String? ?? 'Desconocido',
                    tipo: args?['tipo'] as String? ?? 'Lección',
                  );
                },
                '/usuario_perfil': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, String>?;
                  return UsuarioPerfilScreen(
                    name: args?['name'] ?? '',
                    username: args?['username'] ?? '',
                    imageUrl: args?['imageUrl'] ?? '',
                  );
                },
              },
            );
          },
        );
      },
    );
  }
}
