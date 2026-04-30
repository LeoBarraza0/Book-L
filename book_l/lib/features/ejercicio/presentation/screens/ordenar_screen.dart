import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../calificacion/presentation/screens/resultado_screen.dart';
import '../../domain/entities/ejercicio.dart';

/// Pantalla para resolver ejercicios de tipo Ordenar.
/// El usuario arrastra los elementos hasta colocarlos en el orden correcto.
class OrdenarScreen extends StatefulWidget {
  final Ejercicio ejercicio;
  const OrdenarScreen({super.key, required this.ejercicio});

  @override
  State<OrdenarScreen> createState() => _OrdenarScreenState();
}

class _OrdenarScreenState extends State<OrdenarScreen> {
  int _currentQuestionIndex = 0;
  bool _hasAnswered = false;
  int _respuestasCorrectas = 0;

  // Lista que el usuario reorganiza (índices mezclados)
  List<int> _userOrder = [];
  // Orden correcto (las opciones ya están en orden correcto en la entidad)
  List<String> _correctLabels = [];

  static const _accentColor = Color(0xFF4DB0FF);

  @override
  void initState() {
    super.initState();
    _setupQuestion();
  }

  void _setupQuestion() {
    final pregunta = widget.ejercicio.preguntas[_currentQuestionIndex];
    final count = pregunta.opciones.length;
    _correctLabels = pregunta.opciones.map((o) => o.contenido).toList();
    // Generar orden aleatorio
    _userOrder = List.generate(count, (i) => i)..shuffle();
    _hasAnswered = false;
  }

  bool get _isCorrectOrder {
    for (int i = 0; i < _userOrder.length; i++) {
      if (_userOrder[i] != i) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ejercicio.preguntas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.ejercicio.titulo)),
        body: const Center(child: Text("Este ejercicio aún no tiene preguntas configuradas.")),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 42),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                pregunta.contenido,
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 16,
                                  fontWeight: FontWeight.w600, color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Arrastra los elementos para ordenarlos correctamente',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black45),
                      ),
                      const SizedBox(height: 16),

                      // Lista reordenable
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _userOrder.length,
                        proxyDecorator: (child, index, animation) {
                          return Material(
                            color: Colors.transparent,
                            elevation: 6,
                            borderRadius: BorderRadius.circular(14),
                            child: child,
                          );
                        },
                        onReorder: _hasAnswered ? (_, __) {} : (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = _userOrder.removeAt(oldIndex);
                            _userOrder.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final originalIdx = _userOrder[index];
                          final label = _correctLabels[originalIdx];
                          final isCorrectPos = _hasAnswered && originalIdx == index;
                          final isWrongPos = _hasAnswered && originalIdx != index;

                          Color tileBg;
                          Color borderCol;
                          if (isCorrectPos) {
                            tileBg = const Color(0xFF4DC130).withValues(alpha: 0.1);
                            borderCol = const Color(0xFF4DC130);
                          } else if (isWrongPos) {
                            tileBg = const Color(0xFFFF606F).withValues(alpha: 0.1);
                            borderCol = const Color(0xFFFF606F);
                          } else {
                            tileBg = Colors.white;
                            borderCol = const Color(0xFFE0E0E0);
                          }

                          return Container(
                            key: ValueKey('order_item_$originalIdx'),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: tileBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderCol, width: _hasAnswered ? 2 : 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: _accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(child: Text(
                                    '${index + 1}',
                                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, fontSize: 14, color: _accentColor),
                                  )),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Text(label, style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87,
                                ))),
                                if (!_hasAnswered)
                                  const Icon(Icons.drag_handle_rounded, color: Colors.black26, size: 22),
                                if (isCorrectPos)
                                  const Icon(Icons.check_circle, color: Color(0xFF4DC130), size: 22),
                                if (isWrongPos)
                                  const Icon(Icons.error, color: Color(0xFFFF606F), size: 22),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Feedback
                      if (_hasAnswered) _buildFeedbackBox(_isCorrectOrder, pregunta.explicacion),

                      // Botón confirmar/siguiente
                      _buildActionButton(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 24, left: 20, right: 20,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBox(bool isCorrect, String? explicacion) {
    final bgColor = isCorrect ? const Color(0xFFC7EBB8) : const Color(0xFFF4BDBE);
    final iconBg = isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final titleColor = isCorrect ? const Color(0xFF4DC130) : const Color(0xFFD63030);
    final title = isCorrect ? '¡Orden Correcto!' : '¡Orden Incorrecto!';
    final subtitle = isCorrect
        ? '¡Excelente! ${explicacion ?? ""}'
        : 'Revisa el orden correcto arriba. ${explicacion ?? ""}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(width: 60, height: 60, decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Padding(padding: const EdgeInsets.all(8),
            child: Image.asset('assets/images/Chatbot_Icon.png', fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy, color: Colors.white, size: 30)))),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w900, color: titleColor)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.3, fontWeight: FontWeight.w700, color: Color(0xFF6B6B6B))),
        ])),
      ]),
    );
  }

  Widget _buildActionButton() {
    return Center(
      child: SizedBox(height: 50, width: MediaQuery.of(context).size.width * 0.70,
        child: ElevatedButton(
          onPressed: () {
            if (!_hasAnswered) {
              setState(() { _hasAnswered = true; if (_isCorrectOrder) _respuestasCorrectas++; });
            } else {
              if (_currentQuestionIndex < widget.ejercicio.preguntas.length - 1) {
                setState(() { _currentQuestionIndex++; _setupQuestion(); });
              } else {
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (_) => EjercicioResultadoScreen(
                    totalPreguntas: widget.ejercicio.preguntas.length,
                    respuestasCorrectas: _respuestasCorrectas,
                    ejercicio: widget.ejercicio,
                  ),
                ));
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(!_hasAnswered ? 'Confirmar orden'
              : (_currentQuestionIndex < widget.ejercicio.preguntas.length - 1 ? 'Siguiente pregunta' : 'Terminar intento'),
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildWhiteHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          Align(alignment: Alignment.centerLeft, child: Container(width: 50, height: 50,
            decoration: BoxDecoration(color: _accentColor.withValues(alpha: 0.8), shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context)))),
          SvgPicture.asset('assets/images/logo.svg', height: 72),
        ]),
        const SizedBox(height: 15),
        Text(widget.ejercicio.titulo, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 24, color: Colors.black)),
        const SizedBox(height: 8),
        Text('Pregunta ${_currentQuestionIndex + 1} de ${widget.ejercicio.preguntas.length}',
            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black45)),
      ]),
    );
  }
}
