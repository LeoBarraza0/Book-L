import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/login_screen.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/register_screen.dart';
import 'package:book_l/features/home/infrastructure/adapters/in/presentation/screens/home_screen.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/in/presentation/screens/notificaciones_screen.dart';
import 'package:book_l/features/perfil/infrastructure/adapters/in/presentation/screens/perfil_screen.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/in/presentation/screens/sugerencia_screen.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/in/presentation/screens/configuracion_screen.dart';
import 'package:book_l/features/chatbot/infrastructure/adapters/in/presentation/screens/chatbot_screen.dart';
import 'package:book_l/features/chatbot/infrastructure/adapters/in/presentation/controller/chatbot_controller.dart';
import 'package:book_l/features/chatbot/infrastructure/adapters/out/repositories/chatbot_repository_impl.dart';
import 'package:book_l/features/chatbot/application/usecases/get_respuesta_chatbot_usecase.dart';
import 'package:book_l/features/curso/infrastructure/adapters/in/presentation/screens/curso_detail_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/leccion_detail_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/capitulo_screen.dart';
import 'package:book_l/features/busqueda/infrastructure/adapters/in/presentation/screens/busqueda_screen.dart';
import 'package:book_l/features/busqueda/infrastructure/adapters/in/presentation/screens/resultado_screen.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/screens/teorico_screen.dart';
import 'package:book_l/features/curso/infrastructure/adapters/in/presentation/screens/publicar_curso_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/publicar_leccion_screen.dart';

import 'features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/home/infrastructure/adapters/in/presentation/screens/admin_home_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/admin_leccion_screen.dart';
import 'package:book_l/features/curso/infrastructure/adapters/in/presentation/screens/curso_editar_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/leccion_editar_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/capitulo_editar_screen.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/screens/crear_capitulo_screen.dart';
import 'package:book_l/features/usuarios/infrastructure/adapters/in/presentation/screens/usuarios_screen.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/in/presentation/screens/reportes_screen.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/in/presentation/screens/reporte_detail_screen.dart';

import 'package:book_l/features/onboarding/infrastructure/adapters/in/presentation/screens/bienvenida_screen.dart';
// import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/recuperar_correo_screen.dart';
// import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/recuperar_numero_screen.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/ingresar_codigo_screen.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/screens/cambiar_password_screen.dart';

import 'package:provider/provider.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/auth/infrastructure/adapters/in/presentation/controller/auth_controller.dart';
import 'package:book_l/features/curso/infrastructure/adapters/in/presentation/controller/curso_controller.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/controller/leccion_controller.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/controller/ejercicios_controller.dart';
import 'package:book_l/features/progreso/infrastructure/adapters/in/presentation/controller/progreso_controller.dart';
import 'package:book_l/features/perfil/infrastructure/adapters/in/presentation/controller/perfil_controller.dart';
import 'package:book_l/features/guardado/infrastructure/adapters/in/presentation/controller/guardado_controller.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/in/presentation/controller/discusion_controller.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/controller/calificacion_controller.dart';
import 'package:book_l/features/busqueda/infrastructure/adapters/in/presentation/controller/busqueda_controller.dart';
import 'package:book_l/features/home/infrastructure/adapters/in/presentation/controller/home_controller.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/in/presentation/controller/notificaciones_controller.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/out/repositories/notificacion_repository_impl.dart';
import 'package:book_l/features/notificacion/application/usecases/get_notificaciones_usecase.dart';
import 'package:book_l/features/notificacion/application/usecases/mark_as_read_usecase.dart';
import 'package:book_l/features/usuarios/infrastructure/adapters/in/presentation/controller/usuarios_controller.dart';
import 'package:book_l/features/usuarios/infrastructure/adapters/out/repositories/usuarios_repository_impl.dart';
import 'package:book_l/features/usuarios/application/usecases/get_usuarios_usecase.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/in/presentation/controller/reportes_controller.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/out/repositories/reportes_repository_impl.dart';
import 'package:book_l/features/reportes/application/usecases/get_reportes_agrupados_usecase.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/in/presentation/controller/configuracion_controller.dart';
import 'package:book_l/features/home/infrastructure/adapters/in/presentation/controller/admin_home_controller.dart';
import 'package:book_l/features/reportes/application/usecases/get_estadisticas_reportes_usecase.dart';
import 'package:book_l/features/home/application/usecases/get_novedades_usecase.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/in/presentation/controller/reporte_detail_controller.dart';
import 'package:book_l/features/reportes/application/usecases/get_reportes_por_entidad_usecase.dart';

import 'core/infrastructure/storage/local_storage.dart';

class BookLApp extends StatelessWidget {
  const BookLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BooklService()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CursoController()),
        ChangeNotifierProvider(create: (_) => LeccionController()),
        ChangeNotifierProvider(create: (_) => EjerciciosController()),
        ChangeNotifierProvider(create: (_) => ProgresoController()),
        ChangeNotifierProvider(create: (_) => PerfilController()),
        ChangeNotifierProvider(create: (_) => GuardadoController()),
        ChangeNotifierProvider(create: (_) => DiscusionController()),
        ChangeNotifierProvider(create: (_) => CalificacionController()),
        ChangeNotifierProvider(create: (_) => BusquedaController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(
          create: (_) {
            final repo = NotificacionRepositoryImpl();
            return NotificacionesController(
              getNotificacionesUseCase: GetNotificacionesUseCase(repo),
              markAsReadUseCase: MarkAsReadUseCase(repo),
              authController: AuthController(),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final repo = UsuariosRepositoryImpl();
            return UsuariosController(
              getUsuarios: GetUsuariosUseCase(repo),
              addUsuario: AddUsuarioUseCase(repo),
              updateUsuario: UpdateUsuarioUseCase(repo),
              deleteUsuario: DeleteUsuarioUseCase(repo),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final repo = ReportesRepositoryImpl();
            return ReportesController(
              getReportesAgrupadosUseCase: GetReportesAgrupadosUseCase(repo),
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => ConfiguracionController()),
        ChangeNotifierProvider(
          create: (_) {
            final repo = ReportesRepositoryImpl();
            return AdminHomeController(
              getEstadisticasReportes: GetEstadisticasReportesUseCase(repo),
              getNovedades: GetNovedadesUseCase(),
            );
          },
        ),
      ],
      child: ValueListenableBuilder<bool>(
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
                scaffoldBackgroundColor: const Color(0xFFECEBEB),
                cardColor: Colors.white,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4DC130),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                fontFamily: 'Inter',
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
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
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/notificaciones': (context) => const NotificacionScreen(),
                '/perfil': (context) => const PerfilScreen(),
                '/configuracion': (context) => const ConfiguracionScreen(),
                '/sugerencia': (context) => const SugerenciaScreen(),
                '/chatbot': (context) {
                  final repo = ChatbotRepositoryImpl();
                  return ChangeNotifierProvider(
                    create: (_) => ChatbotController(
                      getRespuesta: GetRespuestaChatbotUseCase(repo),
                    ),
                    child: const ChatbotScreen(),
                  );
                },
                '/curso_detail': (context) => CursoDetailScreen(
                      idCurso:
                          ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/leccion_detail': (context) => LeccionDetailScreen(
                      idLeccion:
                          ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/editar_capitulo': (context) => CapituloEditarScreen(
                      idCapitulo:
                          ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/capitulo_detail': (context) => CapituloScreen(
                      idCapitulo:
                          ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/busqueda': (context) => const BusquedaScreen(),
                '/resultado': (context) => const ResultadoScreen(),
                '/teorico': (context) => TeoricoScreen(
                      ejercicio: ModalRoute.of(context)?.settings.arguments
                          as Ejercicio,
                    ),
                // '/calificacion': (context) => const EjercicioResultadoScreen(),
                '/publicar_curso': (context) => const PublicarCursoScreen(),
                '/publicar_leccion': (context) => const PublicarLeccionScreen(),

                '/admin_Home': (context) => const AdminHomeScreen(),
                '/admin_leccion': (context) => const AdminLeccionScreen(),
                '/editar_curso': (context) => const CursoEditarScreen(),
                '/editar_leccion': (context) => LeccionEditarScreen(
                      idLeccion:
                          ModalRoute.of(context)?.settings.arguments as int?,
                    ),
                '/users_admin': (context) => const UsuariosScreen(),
                '/crear_capitulo': (context) => const CrearCapituloScreen(),
                '/reportes': (context) => const ReportesScreen(),
                '/reporte_detail': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?;
                  final repo = ReportesRepositoryImpl();
                  return ChangeNotifierProvider(
                    create: (_) => ReporteDetailController(
                      getReportesPorEntidadUseCase:
                          GetReportesPorEntidadUseCase(repo),
                    ),
                    child: ReporteDetailScreen(
                      idLeccion: args?['id_leccion'] as int? ?? 0,
                      leccionNombre:
                          args?['nombre'] as String? ?? 'Desconocido',
                      tipo: args?['tipo'] as String? ?? 'Lección',
                    ),
                  );
                },
              },
            );
          },
        );
      },
    ),
  );
}
}
