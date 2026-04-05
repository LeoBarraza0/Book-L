import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/notificacion/presentation/screens/notificaciones_screen.dart';
import 'features/perfil/presentation/screens/perfil_screen.dart';
import 'features/configuracion/presentation/screens/configuracion_screen.dart';
import 'features/chatbot/presentation/screens/chatbot_screen.dart';
import 'features/curso/presentation/screens/curso_detail_screen.dart';

class BookLApp extends StatelessWidget {
  const BookLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book-L',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4DC130)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/notificaciones': (context) => const NotificacionScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/configuracion': (context) => const ConfiguracionScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/curso_detail': (context) => const CursoDetailScreen(),
      },
    );
  }
}
