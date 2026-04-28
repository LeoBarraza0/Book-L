import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/features/leccion/presentation/screens/leccion_detail_screen.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../widgets/stars_rating_widget.dart';

import 'package:book_l/core/storage/local_storage.dart';
import 'package:book_l/core/services/bookl_service.dart';
import 'package:book_l/features/ejercicio/domain/entities/ejercicio.dart';

class EjercicioResultadoScreen extends StatefulWidget {
  final int totalPreguntas;
  final int respuestasCorrectas;
  final Ejercicio ejercicio;

  const EjercicioResultadoScreen({
    super.key,
    required this.totalPreguntas,
    required this.respuestasCorrectas,
    required this.ejercicio,
  });

  @override
  State<EjercicioResultadoScreen> createState() =>
      _EjercicioResultadoScreenState();
}

class _EjercicioResultadoScreenState extends State<EjercicioResultadoScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildWhiteHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      // Tarjeta de Resultados Principal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 30.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4DC130),
                              size: 60,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Felicidades, habeis completado la actividad',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4DC130),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'A continuación veamos qué tal te fue:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Indicador de Puntaje Circular
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: CircularProgressIndicator(
                                      value: widget.totalPreguntas > 0 ? widget.respuestasCorrectas / widget.totalPreguntas : 0,
                                      strokeWidth: 12,
                                      backgroundColor: const Color(
                                        0xFFFF4858,
                                      ), // Rojo de errores
                                      color: const Color(
                                        0xFF4DC130,
                                      ), // Verde de aciertos
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Puntaje',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4DC130),
                                          ),
                                        ),
                                        Text(
                                          '${widget.respuestasCorrectas}/${widget.totalPreguntas}',
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4DC130),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Burbuja de Feedback Chatbot
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF4DC130),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/images/Chatbot_Icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD3E7CE), // Verde suave
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                _getMensajeMascota(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Sección de Calificación (Opcional interactiva)
                      const Text(
                        'Califícanos',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4DC130),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const StarsRatingWidget(
                        showTitle: false,
                        showSendButton: false,
                        starSize: 40,
                      ),
                      const SizedBox(height: 40),

                      // Botón "Listo"
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Mark completion
                            final session = AppSession();
                            final exerciseId = widget.ejercicio.idEjercicio;
                            final capituloId = widget.ejercicio.idCapitulo;
                            
                            // Guardamos que se completó este ejercicio
                            session.marcarEjercicioCompletado(exerciseId, capituloId);

                            // Verificar si todos los ejercicios del capítulo están completados
                            final chapterExercises = BooklService().ejercicios.where((e) => e.idCapitulo == capituloId).map((e) => e.idEjercicio);
                            if (chapterExercises.every((id) => session.completedEjercicios.value.contains(id))) {
                              session.marcarCapituloCompletado(capituloId, true);
                            }

                            // Volvemos a la pantalla de Capítulo
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DC130),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Listo',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Texto "¿Insatisfecho?"
                      GestureDetector(
                        onTap: () {
                          // Acción si el usuario está insatisfecho (opcional)
                        },
                        child: const Text(
                          '¿Insatisfecho?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 100,
                      ), // Espacio para navbar flotante
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8FE67A),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 72,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Resultados',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getMensajeMascota() {
    if (widget.totalPreguntas == 0) return '¡Gran esfuerzo! Sigue así.';
    final score = widget.respuestasCorrectas / widget.totalPreguntas;
    if (score == 1.0) {
      return '¡Perfecto! Eres todo un maestro en este tema. 🤩';
    } else if (score >= 0.7) {
      return '¡Muy bien hecho! Estás muy cerca de la perfección. 🥳';
    } else if (score >= 0.4) {
      return '¡Buen intento! Sigue practicando para lograr mejores resultados. 🙂';
    } else {
      return 'No te desanimes, ¡sigue aprendiendo y lo lograrás! 💪';
    }
  }
}
