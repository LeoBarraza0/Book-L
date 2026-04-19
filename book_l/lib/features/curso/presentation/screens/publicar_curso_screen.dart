import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/custom_button.dart';
import 'package:book_l/shared/widgets/custom_text_field.dart';
import '../controller/curso_controller.dart';

class PublicarCursoScreen extends StatefulWidget {
  const PublicarCursoScreen({super.key});

  @override
  State<PublicarCursoScreen> createState() => _PublicarCursoScreenState();
}

class _PublicarCursoScreenState extends State<PublicarCursoScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController leccionesController = TextEditingController();
  final _cursoCtrl = CursoController();
  bool _guardando = false;

  @override
  void dispose() {
    nombreController.dispose();
    descController.dispose();
    leccionesController.dispose();
    _cursoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Background azulado muy claro
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor Blanco del Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50), // Green back button
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/logo.svg',
                          width: 60,
                          height: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Título dentro del header
                    const Center(
                      child: Text(
                        'Publicar curso',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Texto de Instrucción
                    Text(
                      'Llenar los siguientes datos para poder publicar el curso:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    CustomTextField(
                      controller: nombreController,
                      label: 'Nombre del curso',
                      hint: 'Ej. Introducción a la algoritmia',
                    ),
                    const SizedBox(height: 20),

                    // Custom Multiline Description
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF858484),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: descController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Añade una descripción',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF4DC130), width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lecciones Dropdown mockup
                    CustomTextField(
                      controller: leccionesController,
                      label: 'Lecciones',
                      hint: 'Seleccionar...',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    const SizedBox(height: 12),

                    // Crear Lección button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/publicar_leccion');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Crear lección',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Cargar Archivo (Fondo de imagen)
                    const Text(
                      'Fondo de imagen',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF858484),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        // Implement upload logic later
                      },
                      child: Container(
                        height: 52, // Match CustomTextField height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x15000000),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 16),
                            Icon(Icons.file_upload_outlined, color: Colors.grey),
                            SizedBox(width: 12),
                            Text(
                              'Cargar archivo',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey, // Gris como indicó el subagent
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botón Publicar
                    CustomButton(
                      label: _guardando ? 'Publicando...' : 'Publicar',
                      onPressed: _guardando ? null : _guardarCurso,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarCurso() async {
    final nombre = nombreController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre del curso es obligatorio')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await _cursoCtrl.agregarCurso(
        nombre: nombre,
        introduccion: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Curso publicado exitosamente',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}
