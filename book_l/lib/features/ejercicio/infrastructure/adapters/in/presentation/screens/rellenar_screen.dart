import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/screens/resultado_screen.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/controller/ejercicios_controller.dart';

/// Pantalla para resolver ejercicios de tipo Rellenar.
/// Muestra el enunciado con espacios en blanco y el usuario escribe las palabras faltantes.
class RellenarScreen extends StatefulWidget {
  final Ejercicio ejercicio;
  const RellenarScreen({super.key, required this.ejercicio});

  @override
  State<RellenarScreen> createState() => _RellenarScreenState();
}

class _RellenarScreenState extends State<RellenarScreen> {
  int _currentQuestionIndex = 0;
  bool _hasAnswered = false;
  int _respuestasCorrectas = 0;
  List<TextEditingController> _inputCtrls = [];
  List<bool?> _resultados = [];

  static const _accentColor = Color(0xFFFF606F);

  @override
  void initState() {
    super.initState();
    _setupQuestion();
  }

  void _setupQuestion() {
    // Limpiar controladores anteriores
    for (final c in _inputCtrls) {
      c.dispose();
    }
    final pregunta = widget.ejercicio.preguntas[_currentQuestionIndex];
    _inputCtrls =
        List.generate(pregunta.opciones.length, (_) => TextEditingController());
    _resultados = List.filled(pregunta.opciones.length, null);
    _hasAnswered = false;
  }

  @override
  void dispose() {
    for (final c in _inputCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _verificar() {
    final pregunta = widget.ejercicio.preguntas[_currentQuestionIndex];
    bool allCorrect = true;
    for (int i = 0; i < pregunta.opciones.length; i++) {
      final expected = pregunta.opciones[i].contenido.trim().toLowerCase();
      final userAnswer = _inputCtrls[i].text.trim().toLowerCase();
      final ok = expected == userAnswer;
      _resultados[i] = ok;
      if (!ok) allCorrect = false;
    }
    if (allCorrect) _respuestasCorrectas++;
    setState(() => _hasAnswered = true);
    
    EjerciciosController().guardarRespuesta(
      AppSession().usuarioId ?? 0,
      pregunta.idPregunta,
      null,
      allCorrect,
    );
  }

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
    final allCorrect = _resultados.every((r) => r == true);

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
                            const Icon(Icons.text_fields_rounded,
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
                      const SizedBox(height: 8),
                      const Text(
                        'Escribe las palabras que faltan en cada espacio',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.black45),
                      ),
                      const SizedBox(height: 20),

                      // Campos de entrada
                      ...List.generate(pregunta.opciones.length, (i) {
                        final resultado = _resultados[i];
                        Color borderColor;
                        IconData? trailingIcon;
                        if (resultado == true) {
                          borderColor = const Color(0xFF4DC130);
                          trailingIcon = Icons.check_circle;
                        } else if (resultado == false) {
                          borderColor = const Color(0xFFFF606F);
                          trailingIcon = Icons.error;
                        } else {
                          borderColor = const Color(0xFFE0E0E0);
                          trailingIcon = null;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Espacio ${i + 1}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _accentColor,
                                  )),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: borderColor,
                                      width: resultado != null ? 2 : 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _inputCtrls[i],
                                  enabled: !_hasAnswered,
                                  style: const TextStyle(
                                      fontFamily: 'Inter', fontSize: 15),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    border: InputBorder.none,
                                    hintText: 'Escribe aquí...',
                                    hintStyle: const TextStyle(
                                        color: Color(0xFFBBBBBB), fontSize: 14),
                                    suffixIcon: trailingIcon != null
                                        ? Icon(trailingIcon,
                                            color: borderColor, size: 22)
                                        : null,
                                  ),
                                ),
                              ),
                              // Mostrar respuesta correcta si se equivocó
                              if (resultado == false)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, left: 8),
                                  child: Text(
                                    'Respuesta: ${pregunta.opciones[i].contenido}',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF4DC130),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // Feedback
                      if (_hasAnswered)
                        _buildFeedbackBox(allCorrect, pregunta.explicacion),

                      // Botón confirmar/siguiente
                      _buildActionButton(allCorrect),
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

  Widget _buildFeedbackBox(bool isCorrect, String? explicacion) {
    final bgColor =
        isCorrect ? const Color(0xFFC7EBB8) : const Color(0xFFF4BDBE);
    final iconBg =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final titleColor =
        isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final title = isCorrect ? '¡Correcto!' : '¡Incorrecto!';
    final subtitle = isCorrect
        ? '¡Todas las palabras son correctas! ${explicacion ?? ""}'
        : 'Revisa las respuestas correctas arriba. ${explicacion ?? ""}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/Chatbot_Icon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy,
                        color: Colors.white, size: 30)))),
        const SizedBox(width: 15),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
        ])),
      ]),
    );
  }

  Widget _buildActionButton(bool allCorrect) {
    final canSubmit =
        !_hasAnswered && _inputCtrls.any((c) => c.text.trim().isNotEmpty);
    return Center(
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.70,
        child: ElevatedButton(
          onPressed: !_hasAnswered
              ? (canSubmit ? _verificar : null)
              : () {
                  if (_currentQuestionIndex <
                      widget.ejercicio.preguntas.length - 1) {
                    setState(() {
                      _currentQuestionIndex++;
                      _setupQuestion();
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
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            disabledBackgroundColor: Colors.grey.shade400,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
              !_hasAnswered
                  ? 'Verificar respuestas'
                  : (_currentQuestionIndex <
                          widget.ejercicio.preguntas.length - 1
                      ? 'Siguiente pregunta'
                      : 'Terminar intento'),
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
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
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))),
      child: Column(children: [
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
                      onPressed: () => Navigator.pop(context)))),
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
      ]),
    );
  }
}
