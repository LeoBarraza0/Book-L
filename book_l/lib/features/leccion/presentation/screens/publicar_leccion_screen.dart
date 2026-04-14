import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/custom_button.dart';
import 'package:book_l/shared/widgets/custom_text_field.dart';

class PublicarLeccionScreen extends StatefulWidget {
  const PublicarLeccionScreen({super.key});

  @override
  State<PublicarLeccionScreen> createState() => _PublicarLeccionScreenState();
}

class _PublicarLeccionScreenState extends State<PublicarLeccionScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController cursoController = TextEditingController();
  final TextEditingController savedExController = TextEditingController();

  int chapterCount = 1;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    cursoController.dispose();
    savedExController.dispose();
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
                      label: 'Nombre de la clase',
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
                      label: 'Curso',
                      hint: 'Elige una opción...',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    const SizedBox(height: 30),
                    // Dynamic Chapters
                    ...List.generate(chapterCount, (index) => _buildChapterBlock(index)),

                    // Botón Añadir Capítulo Dashed Box
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          chapterCount++;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(
                          painter: _DottedBorderPainter(
                            color: const Color(0xFFB0B0B0),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFFB0B0B0),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Añadir Capítulo',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Subir video / material
                    const Text(
                      'Subir video/Material de estudio',
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
                        ),
                        child: CustomPaint(
                          painter: _DottedBorderPainter(
                            color: const Color(0xFFB0B0B0),
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
                    ),
                    const SizedBox(height: 40),

                    // Añadir Ejercicio
                    const Text(
                      'Añadir ejercicio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Ejercicio Teórico
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/crear_ejercicio_teorico',
                              ),
                              child: CustomPaint(
                                painter: _DottedBorderPainter(
                                  color: const Color(0xFFB0B0B0),
                                  isCircle: true,
                                ),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFFB0B0B0),
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Teórico',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        // Ejercicio Práctico
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/crear_ejercicio_practico',
                              ),
                              child: CustomPaint(
                                painter: _DottedBorderPainter(
                                  color: const Color(0xFFB0B0B0),
                                  isCircle: true,
                                ),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Color(0xFFB0B0B0),
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Práctico',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Ejercicios guardados
                    CustomTextField(
                      controller: savedExController,
                      label: 'Ejercicios guardados',
                      hint: 'Elige una opción...',
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    const SizedBox(height: 40),

                    // Botón Final
                    CustomButton(
                      label: '¡Subir ya!',
                      onPressed: () => Navigator.pushNamed(context, '/perfil'),
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

  Widget _buildToolbarIcon(IconData icon) {
    return Icon(icon, color: const Color(0xFFB0B0B0), size: 22);
  }

  Widget _buildChapterBlock(int index) {
    return Column(
      key: ValueKey('chapter_$index'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capítulo ${index + 1}:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildToolbarIcon(Icons.format_bold),
                    _buildToolbarIcon(Icons.format_italic),
                    _buildToolbarIcon(Icons.format_underlined),
                    _buildToolbarIcon(Icons.strikethrough_s),
                    _buildToolbarIcon(Icons.format_align_left),
                    _buildToolbarIcon(Icons.link),
                    _buildToolbarIcon(Icons.image_outlined),
                  ],
                ),
              ),
              Container(
                height: 150,
                padding: const EdgeInsets.all(12),
                child: const TextField(
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Añade un texto...',
                    hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Simple dotted border painter
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final bool isCircle;

  _DottedBorderPainter({required this.color, this.isCircle = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    Path rrectPath = Path();
    if (isCircle) {
      rrectPath.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      );
      rrectPath.addRRect(rrect);
    }
    
    var dottedPath = Path();
    for (var metric in rrectPath.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dottedPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dottedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
