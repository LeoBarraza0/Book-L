import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/screens/resultado_screen.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/controller/ejercicios_controller.dart';

/// Pantalla para resolver ejercicios de tipo Verdadero/Falso.
/// Muestra dos botones grandes para seleccionar la respuesta.
class VerdaderoFalsoScreen extends StatefulWidget {
  final Ejercicio ejercicio;
  const VerdaderoFalsoScreen({super.key, required this.ejercicio});

  @override
  State<VerdaderoFalsoScreen> createState() => _VerdaderoFalsoScreenState();
}

class _VerdaderoFalsoScreenState extends State<VerdaderoFalsoScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedIndex; // 0 = Verdadero, 1 = Falso
  bool _hasAnswered = false;
  int _respuestasCorrectas = 0;

  static const _accentColor = Color(0xFFF6B55C);

  @override
  Widget build(BuildContext context) {
    if (widget.ejercicio.preguntas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.ejercicio.titulo)),
        body: const Center(
            child: Text("Este ejercicio aún no tiene preguntas configuradas.")),
      );
    }

    final pregunta = widget.ejercicio.preguntas[_currentQuestionIndex];
    final correctIndex = pregunta.opciones.indexWhere((o) => o.correcta);
    final isCorrect = _selectedIndex == correctIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildWhiteHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Tarjeta de pregunta
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.help_outline,
                                color: Colors.white, size: 42),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                pregunta.contenido,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botones Verdadero / Falso
                      Row(
                        children: [
                          _buildOptionButton(
                            index: 0,
                            label: 'Verdadero',
                            icon: Icons.check_circle_rounded,
                            selectedColor: const Color(0xFF4DC130),
                          ),
                          const SizedBox(width: 16),
                          _buildOptionButton(
                            index: 1,
                            label: 'Falso',
                            icon: Icons.cancel_rounded,
                            selectedColor: const Color(0xFFFF606F),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Feedback
                      if (_hasAnswered)
                        _buildFeedbackBox(isCorrect, pregunta.opciones,
                            correctIndex, pregunta.explicacion),

                      // Botón confirmar/siguiente
                      _buildActionButton(isCorrect),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String label,
    required IconData icon,
    required Color selectedColor,
  }) {
    final isSelected = _selectedIndex == index;
    final showCorrect = _hasAnswered &&
        widget.ejercicio.preguntas[_currentQuestionIndex].opciones[index]
            .correcta;
    final showWrong = _hasAnswered &&
        isSelected &&
        !widget.ejercicio.preguntas[_currentQuestionIndex].opciones[index]
            .correcta;

    Color bgColor;
    if (showCorrect) {
      bgColor = const Color(0xFF4DC130).withValues(alpha: 0.15);
    } else if (showWrong) {
      bgColor = const Color(0xFFFF606F).withValues(alpha: 0.15);
    } else if (isSelected) {
      bgColor = selectedColor.withValues(alpha: 0.12);
    } else {
      bgColor = const Color(0xFFDFDFDF);
    }

    Color borderColor;
    if (showCorrect) {
      borderColor = const Color(0xFF4DC130);
    } else if (showWrong) {
      borderColor = const Color(0xFFFF606F);
    } else if (isSelected) {
      borderColor = selectedColor;
    } else {
      borderColor = const Color(0xFFE0E0E0);
    }

    return Expanded(
      child: GestureDetector(
        onTap:
            _hasAnswered ? null : () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 120,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: borderColor,
                width: isSelected || showCorrect || showWrong ? 2.5 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 40, color: isSelected ? selectedColor : Colors.black38),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? selectedColor : Colors.black54,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBox(
      bool isCorrect, List opciones, int correctIndex, String? explicacion) {
    final bgColor =
        isCorrect ? const Color(0xFFC7EBB8) : const Color(0xFFF4BDBE);
    final iconBgColor =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final titleColor =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final title = isCorrect ? '¡Correcto!' : '¡Incorrecto!';
    final subtitle = isCorrect
        ? '¡Excelente! ${explicacion ?? ""}'
        : 'La respuesta correcta es: ${correctIndex == 0 ? "Verdadero" : "Falso"}\n${explicacion ?? ""}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration:
                BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset('assets/images/Chatbot_Icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy,
                      color: Colors.white, size: 30)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: titleColor)),
              const SizedBox(height: 5),
              Text(subtitle,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B6B6B))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isCorrect) {
    return Center(
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.70,
        child: ElevatedButton(
          onPressed: _selectedIndex != null
              ? () {
                  if (!_hasAnswered) {
                    setState(() {
                      _hasAnswered = true;
                      if (isCorrect) _respuestasCorrectas++;
                    });
                    EjerciciosController().guardarRespuesta(
                      AppSession().usuarioId ?? 0,
                      widget.ejercicio.preguntas[_currentQuestionIndex].idPregunta,
                      widget.ejercicio.preguntas[_currentQuestionIndex].opciones[_selectedIndex!].idOpcion,
                      isCorrect,
                    );
                  } else {
                    if (_currentQuestionIndex <
                        widget.ejercicio.preguntas.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                        _selectedIndex = null;
                        _hasAnswered = false;
                      });
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EjercicioResultadoScreen(
                              totalPreguntas: widget.ejercicio.preguntas.length,
                              respuestasCorrectas: _respuestasCorrectas,
                              ejercicio: widget.ejercicio,
                            ),
                          ));
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            disabledBackgroundColor: Colors.grey.shade400,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            !_hasAnswered
                ? 'Confirmar respuesta'
                : (_currentQuestionIndex < widget.ejercicio.preguntas.length - 1
                    ? 'Siguiente pregunta'
                    : 'Terminar intento'),
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _selectedIndex != null ? Colors.white : Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Stack(alignment: Alignment.center, children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.8),
                      shape: BoxShape.circle),
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context)),
                )),
            SvgPicture.asset('assets/images/logo.svg', height: 72),
          ]),
          const SizedBox(height: 15),
          Text(widget.ejercicio.titulo,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black)),
          const SizedBox(height: 8),
          Text(
              'Pregunta ${_currentQuestionIndex + 1} de ${widget.ejercicio.preguntas.length}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black45)),
        ],
      ),
    );
  }
}
