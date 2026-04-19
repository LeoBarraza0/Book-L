import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/custom_button.dart';
import 'package:book_l/shared/widgets/custom_text_field.dart';
import '../widgets/agregar_seccion_button.dart';
import '../controller/leccion_controller.dart';
import '../../../../core/storage/local_storage.dart';

class PublicarLeccionScreen extends StatefulWidget {
  const PublicarLeccionScreen({super.key});

  @override
  State<PublicarLeccionScreen> createState() => _PublicarLeccionScreenState();
}

class _PublicarLeccionScreenState extends State<PublicarLeccionScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();
  final _leccionCtrl = LeccionController();
  bool _guardando = false;

  final List<String> _capitulos = ['Capítulo 1 - Introducción'];

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    cursoController.dispose();
    _leccionCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
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
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
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
                    const Center(
                      child: Text(
                        'Publicar Lección',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texto Instruccional
                    Text(
                      'Por favor llenar los siguientes datos:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),

                    // Nombre de la clase
                    CustomTextField(
                      controller: nameController,
                      label: 'Nombre de la lección',
                      hint: 'Ingresa el nombre...',
                    ),
                    const SizedBox(height: 20),

                    // Descripción Multilínea
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
                          hintStyle: const TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 15,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEEEEEE),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEEEEEE),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4DC130),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Combobox Curso
                    CustomTextField(
                      controller: cursoController,
                      label: 'Curso asignado',
                      hint: 'Elige una opción...',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    const SizedBox(height: 30),

                    // Lista de Capítulos Dinámicos
                    const Text(
                      'Capítulos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_capitulos.length, (index) => _buildChapterBlock(index, _capitulos[index])),

                    // Botón Añadir Capítulo 
                    AgregarSeccionButton(
                      titulo: 'Añadir Capítulo',
                      onTap: () {
                        // Navegamos al editor de capítulos y opcionalmente añadimos a la lista
                        Navigator.pushNamed(context, '/editar_capitulo');
                      },
                    ),
                    const SizedBox(height: 30),

                    // Subir video / material
                    const Text(
                      'Subir material de la lección',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF858484),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Color(0xFFB0B0B0),
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Cargar Archivo',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),


                    const SizedBox(height: 40),

                    // Botón Final
                    CustomButton(
                      label: _guardando ? 'Guardando...' : '¡Guardar Lección!',
                      onPressed: _guardando ? null : _guardarLeccion,
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

  // Elemento resumido para mostrar un capítulo existente en la lección
  Widget _buildChapterBlock(int index, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF4DC130),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/editar_capitulo');
            },
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF4DC130)),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarLeccion() async {
    final nombre = nameController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre de la lección es obligatorio')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      await _leccionCtrl.agregarLeccion(
        idUsuario: AppSession().usuarioId ?? 1,
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
              Text('Lección guardada exitosamente',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
