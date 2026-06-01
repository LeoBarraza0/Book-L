import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/screens/resultado_screen.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/domain/models/opcion.dart';

class TeoricoScreen extends StatefulWidget {
  final Ejercicio ejercicio;

  const TeoricoScreen({super.key, required this.ejercicio});

  @override
  State<TeoricoScreen> createState() => _TeoricoScreenState();
}

class _TeoricoScreenState extends State<TeoricoScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedIndex;
  bool _hasAnswered = false;
  int _respuestasCorrectas = 0;

  final List<String> _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    if (widget.ejercicio.preguntas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.ejercicio.titulo)),
        body: const Center(
            child: Text("Este ejercicio aún no tiene preguntas configuradas.")),
      );
    }

    final preguntaActual = widget.ejercicio.preguntas[_currentQuestionIndex];

    // Obtiene la opción correcta desde la entidad
    final correctIndex = preguntaActual.opciones.indexWhere((o) => o.correcta);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      // Tarjeta de Pregunta
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DC130),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 42,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                preguntaActual.contenido,
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
                      const SizedBox(height: 20),

                      // Opciones de Selección
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: preguntaActual.opciones.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedIndex == index;
                          final opcion = preguntaActual.opciones[index];

                          return GestureDetector(
                            onTap: _hasAnswered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4DC130)
                                    : const Color(0xFFDFDFDF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFB0B0B0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        index < _letters.length
                                            ? _letters[index]
                                            : '-',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      opcion.contenido,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // Feedback Box
                      if (_hasAnswered)
                        _buildFeedbackBox(isCorrect, preguntaActual.opciones,
                            correctIndex, preguntaActual.explicacion),

                      // Botón Inferior dinámico
                      Center(
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
                                    } else {
                                      // Next question or Final Screen
                                      if (_currentQuestionIndex <
                                          widget.ejercicio.preguntas.length -
                                              1) {
                                        setState(() {
                                          _currentQuestionIndex++;
                                          _selectedIndex = null;
                                          _hasAnswered = false;
                                        });
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EjercicioResultadoScreen(
                                              totalPreguntas: widget
                                                  .ejercicio.preguntas.length,
                                              respuestasCorrectas:
                                                  _respuestasCorrectas,
                                              ejercicio: widget.ejercicio,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DC130),
                              disabledBackgroundColor: Colors.grey.shade400,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              !_hasAnswered
                                  ? 'Confirmar respuesta'
                                  : (_currentQuestionIndex <
                                          widget.ejercicio.preguntas.length - 1
                                      ? 'Siguiente pregunta'
                                      : 'Terminar intento'),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _selectedIndex != null
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),

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

  Widget _buildFeedbackBox(bool isCorrect, List<Opcion> opciones,
      int correctIndex, String? explicacion) {
    final bgColor =
        isCorrect ? const Color(0xFFC7EBB8) : const Color(0xFFF4BDBE);
    final iconBgColor =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final titleTextColor =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);

    final title = isCorrect ? '¡Correcto!' : '¡Incorrecto!';

    String subtitle = '¡Excelente trabajo! Has respondido correctamente';
    if (!isCorrect) {
      final textoCorrecto =
          correctIndex != -1 ? opciones[correctIndex].contenido : 'ninguna';
      subtitle =
          'La respuesta correcta es: $textoCorrecto\n${explicacion ?? ""}';
    } else {
      if (explicacion != null && explicacion.isNotEmpty) {
        subtitle += '\n$explicacion';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      margin: const EdgeInsets.only(bottom: 30.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/Chatbot_Icon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.smart_toy, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: titleTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
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
          Text(
            widget.ejercicio.titulo,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pregunta ${_currentQuestionIndex + 1} de ${widget.ejercicio.preguntas.length}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
