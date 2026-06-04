import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/in/presentation/screens/resultado_screen.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/in/presentation/controller/ejercicios_controller.dart';

/// Pantalla para resolver ejercicios de tipo Respuesta Corta.
/// El usuario escribe su respuesta y se compara con la esperada.
class RespuestaCortaScreen extends StatefulWidget {
  final Ejercicio ejercicio;
  const RespuestaCortaScreen({super.key, required this.ejercicio});

  @override
  State<RespuestaCortaScreen> createState() => _RespuestaCortaScreenState();
}

class _RespuestaCortaScreenState extends State<RespuestaCortaScreen> {
  int _currentQuestionIndex = 0;
  bool _hasAnswered = false;
  int _respuestasCorrectas = 0;
  final TextEditingController _answerCtrl = TextEditingController();
  bool? _isCorrect;

  static const _accentColor = Color(0xFF9B51E0);

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  void _verificar() {
    final pregunta = widget.ejercicio.preguntas[_currentQuestionIndex];
    if (pregunta.opciones.isEmpty) return;
    final expected = pregunta.opciones.first.contenido.trim().toLowerCase();
    final userAnswer = _answerCtrl.text.trim().toLowerCase();
    final correct = expected == userAnswer;
    if (correct) _respuestasCorrectas++;
    setState(() {
      _isCorrect = correct;
      _hasAnswered = true;
    });

    EjerciciosController().guardarRespuesta(
      AppSession().usuarioId ?? 0,
      pregunta.idPregunta,
      null,
      correct,
    );
  }

  void _siguiente() {
    if (_currentQuestionIndex < widget.ejercicio.preguntas.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answerCtrl.clear();
        _isCorrect = null;
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
                            const Icon(Icons.short_text_rounded,
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
                      const SizedBox(height: 24),

                      // Campo de respuesta
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isCorrect == null
                                ? const Color(0xFFE0E0E0)
                                : (_isCorrect!
                                    ? const Color(0xFF4DC130)
                                    : const Color(0xFFFF606F)),
                            width: _isCorrect != null ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _answerCtrl,
                          enabled: !_hasAnswered,
                          maxLines: 3,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: Colors.black87),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(18),
                            border: InputBorder.none,
                            hintText: 'Escribe tu respuesta aquí...',
                            hintStyle: const TextStyle(
                                color: Color(0xFFBBBBBB), fontSize: 14),
                            suffixIcon: _isCorrect != null
                                ? Icon(
                                    _isCorrect!
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _isCorrect!
                                        ? const Color(0xFF4DC130)
                                        : const Color(0xFFFF606F),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      // Respuesta correcta si se equivocó
                      if (_isCorrect == false && pregunta.opciones.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: Color(0xFF4DC130), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Respuesta esperada: ${pregunta.opciones.first.contenido}',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: Color(0xFF4DC130),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Feedback
                      if (_hasAnswered)
                        _buildFeedbackBox(
                            _isCorrect ?? false, pregunta.explicacion),

                      // Botón
                      _buildActionButton(),
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
        ? '¡Excelente respuesta! ${explicacion ?? ""}'
        : 'No te preocupes, revisa la respuesta correcta. ${explicacion ?? ""}';

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

  Widget _buildActionButton() {
    final canSubmit = !_hasAnswered && _answerCtrl.text.trim().isNotEmpty;
    return Center(
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.70,
        child: ElevatedButton(
          onPressed:
              !_hasAnswered ? (canSubmit ? _verificar : null) : _siguiente,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            disabledBackgroundColor: Colors.grey.shade400,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
              !_hasAnswered
                  ? 'Verificar respuesta'
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
