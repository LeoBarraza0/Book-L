import 'package:flutter/material.dart';
import 'package:book_l/shared/widgets/custom_button.dart';
import 'package:book_l/shared/widgets/custom_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/data/local_db_service.dart';
import '../../../../shared/domain/models/ejercicio_model.dart';

class CrearEjercicioPracticoScreen extends StatefulWidget {
  const CrearEjercicioPracticoScreen({super.key});

  @override
  State<CrearEjercicioPracticoScreen> createState() => _CrearEjercicioPracticoScreenState();
}

class QuestionData {
  final TextEditingController descController = TextEditingController();
  final TextEditingController responseController = TextEditingController();
  final TextEditingController correctOptionController = TextEditingController();

  void dispose() {
    descController.dispose();
    responseController.dispose();
    correctOptionController.dispose();
  }
}

class _CrearEjercicioPracticoScreenState extends State<CrearEjercicioPracticoScreen> {
  final TextEditingController reqController = TextEditingController();
  List<QuestionData> questions = [QuestionData()];

  @override
  void dispose() {
    reqController.dispose();
    for (var q in questions) {
      q.dispose();
    }
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
                              color: Color(0xFF4CAF50),
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
                    const Center(
                      child: Text(
                        'Ejercicio práctico',
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
                    // General Description
                    CustomTextField(
                      controller: reqController,
                      label: 'Descripción:',
                      hint: 'Escribe las instrucciones generales...',
                    ),
                    const SizedBox(height: 30),

                    // Dynamic Question Blocks
                    ...List.generate(questions.length, (index) => _buildQuestionBlock(index)),

                    // Añadir Pregunta Dashed Box
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          questions.add(QuestionData());
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
                          painter: _DottedBorderPainter(color: const Color(0xFFB0B0B0)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: Color(0xFFB0B0B0), size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Añadir Pregunta',
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
                    const SizedBox(height: 50),

                    Center(
                      child: SizedBox(
                        width: 160,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            final List<EjercicioModel> results = [];
                            for (var q in questions) {
                              if (q.descController.text.isEmpty) continue;
                              
                              results.add(EjercicioModel(
                                id: LocalDbService.instance.generateId(),
                                pregunta: q.descController.text,
                                tipo: 'practica',
                                respuestaCorrecta: q.correctOptionController.text,
                                instrucciones: reqController.text, // Instrucciones generales
                              ));
                            }
                            Navigator.pop(context, results);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildQuestionBlock(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta ${index + 1}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          
          // Descripción Box
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
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
              controller: questions[index].descController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Descripción...',
                hintStyle: TextStyle(color: Color(0xFF858484), fontWeight: FontWeight.bold),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Respuesta Box
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
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
              controller: questions[index].responseController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Respuesta...',
                hintStyle: TextStyle(color: Color(0xFF858484), fontWeight: FontWeight.bold),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Opción correcta Box
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Opción correcta:',
                    style: TextStyle(
                      color: Color(0xFF858484),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: questions[index].correctOptionController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;

  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    
    var path = Path()..addRRect(rrect);
    var dottedPath = Path();
    for (var metric in path.computeMetrics()) {
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
