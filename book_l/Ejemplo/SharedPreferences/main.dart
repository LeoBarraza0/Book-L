import 'package:flutter/material.dart';
import 'preferences_service.dart';
import 'home_screen.dart';
import 'form_screen.dart';
import 'profile_screen.dart';

void main() async {
  // Permite ejecutar código async antes de iniciar la app
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializamos SharedPreferences
  await PreferencesService().init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesService();

    // Obtenemos el color guardado
    String colorSaved = prefs.getColor();

    // Convertimos el string en color real
    MaterialColor primaryColor = colorSaved == "red" ? Colors.red : Colors.blue;

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Rutas nombradas
      initialRoute: "/",
      routes: {
        "/": (context) => HomeScreen(refreshApp: refreshApp),
        "/form": (context) => FormScreen(refreshApp: refreshApp),
        "/profile": (context) => ProfileScreen(),
      },

      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
    );
  }

  /// Método para reconstruir la app cuando cambia el color
  void refreshApp() {
    setState(() {});
  }
}
