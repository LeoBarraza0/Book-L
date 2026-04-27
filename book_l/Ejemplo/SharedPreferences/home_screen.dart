import 'package:flutter/material.dart';
import 'preferences_service.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback refreshApp;

  const HomeScreen({required this.refreshApp});

  @override
  Widget build(BuildContext context) {
    final prefs = PreferencesService();
    String colorSaved = prefs.getColor();

    return Scaffold(
      appBar: AppBar(
        title: Text("Inicio"),
      ),

      // Drawer genera automáticamente el botón hamburguesa
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorSaved == "red" ? Colors.red : Colors.blue,
              ),
              child: Text(
                "Menú Principal",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Inicio"),
              onTap: () {
                Navigator.pushNamed(context, "/");
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Formulario"),
              onTap: () {
                Navigator.pushNamed(context, "/form");
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Perfil"),
              onTap: () {
                Navigator.pushNamed(context, "/profile");
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: Text(
          "Bienvenido a tu primera app",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
