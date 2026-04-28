import 'package:flutter/material.dart';
import 'preferences_service.dart';

class FormScreen extends StatefulWidget {
  final VoidCallback refreshApp;

  const FormScreen({super.key, required this.refreshApp});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final prefs = PreferencesService();
  final TextEditingController nameController = TextEditingController();

  String gender = "Masculino";
  String color = "blue";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Formulario")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Campo Nombre
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),

            SizedBox(height: 20),

            // Dropdown Género
            DropdownButton<String>(
              value: gender,
              items: ["Masculino", "Femenino"]
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(g),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
            ),

            SizedBox(height: 20),

            // Dropdown Color
            DropdownButton<String>(
              value: color,
              items: ["blue", "red"]
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  color = value!;
                });
              },
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                // Guardamos datos en SharedPreferences
                await prefs.saveName(nameController.text);
                await prefs.saveGender(gender);
                await prefs.saveColor(color);

                // Actualizamos la app para cambiar color
                widget.refreshApp();

                Navigator.pop(context);
              },
              child: Text("Guardar"),
            )
          ],
        ),
      ),
    );
  }
}
