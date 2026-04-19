import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/notificacion/presentation/screens/notificaciones_screen.dart';
import 'features/perfil/presentation/screens/perfil_screen.dart';
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
import 'features/ejercicio/presentation/screens/crear_ejercicio_teorico_screen.dart';
import 'features/ejercicio/presentation/screens/crear_ejercicio_practico_screen.dart';
import 'features/home/presentation/screens/admin_home_screen.dart';
import 'features/leccion/presentation/screens/admin_leccion_screen.dart';
import 'features/curso/presentation/screens/curso_editar_screen.dart';
import 'features/leccion/presentation/screens/leccion_editar_screen.dart';
import 'features/leccion/presentation/screens/capitulo_editar_screen.dart';
import 'features/usuarios/presentation/screens/usuarios_screen.dart';
import 'features/usuarios/presentation/screens/edit_usuario_screen.dart';
import 'core/storage/local_storage.dart';

class BookLApp extends StatelessWidget {
  const BookLApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DC130)),
        useMaterial3: true,
      ),
      initialRoute: AppSession().estaLogueado ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notificaciones': (context) => const NotificacionScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/configuracion': (context) => const ConfiguracionScreen(),
        '/chatbot': (context) => const ChatbotScreen(),

        // Rutas que reciben un ID como argumento (int)
        '/curso_detail': (context) => CursoDetailScreen(
              idCurso: ModalRoute.of(context)?.settings.arguments as int?,
            ),
        '/leccion_detail': (context) => LeccionDetailScreen(
              idLeccion: ModalRoute.of(context)?.settings.arguments as int?,
            ),
        '/editar_capitulo': (context) => CapituloEditarScreen(
              idCapitulo: ModalRoute.of(context)?.settings.arguments as int?,
            ),

        '/capitulo_detail': (context) => const CapituloScreen(),
        '/busqueda': (context) => const BusquedaScreen(),
        '/resultado': (context) => const ResultadoScreen(),
        '/teorico': (context) => const TeoricoScreen(),
        '/calificacion': (context) => const EjercicioResultadoScreen(),
        '/publicar_curso': (context) => const PublicarCursoScreen(),
        '/publicar_leccion': (context) => const PublicarLeccionScreen(),
        '/crear_ejercicio_teorico': (context) =>
            const CrearEjercicioTeoricoScreen(),
        '/crear_ejercicio_practico': (context) =>
            const CrearEjercicioPracticoScreen(),
        '/admin_Home': (context) => const AdminHomeScreen(),
        '/admin_leccion': (context) => const AdminLeccionScreen(),
        '/editar_curso': (context) => const CursoEditarScreen(),
        '/editar_leccion': (context) => LeccionEditarScreen(
              idLeccion: ModalRoute.of(context)?.settings.arguments as int?,
            ),
        '/users_admin': (context) => const UsuariosScreen(),
      },
    );
  }
}
