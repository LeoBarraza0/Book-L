import 'package:flutter/material.dart';
import 'preferences_service.dart';

class ProfileScreen extends StatelessWidget {
  final prefs = PreferencesService();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String name = prefs.getName();
    String gender = prefs.getGender();

    return Scaffold(
      appBar: AppBar(title: Text("Perfil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nombre: $name",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Género: $gender",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
