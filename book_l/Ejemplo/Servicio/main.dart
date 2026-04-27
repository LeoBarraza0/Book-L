import 'package:flutter/material.dart';
import 'UI/pages/home_page.dart';

// Punto de entrada de la app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
