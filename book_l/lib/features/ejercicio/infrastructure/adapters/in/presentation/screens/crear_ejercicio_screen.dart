import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import '../controller/ejercicios_controller.dart';

class CrearEjercicioScreen extends StatefulWidget {
  final int idCapitulo;
  final TipoEjercicio tipo;

  const CrearEjercicioScreen({
    super.key,
    required this.idCapitulo,
    required this.tipo,
  });

  @override
  State<CrearEjercicioScreen> createState() => _CrearEjercicioScreenState();
}

class _QuestionData {
  final TextEditingController contenidoCtrl = TextEditingController();
  final TextEditingController explicacionCtrl = TextEditingController();
  final List<_OpcionData> opciones;

  _QuestionData({int numOpciones = 4})
      : opciones = List.generate(numOpciones, (_) => _OpcionData());

  void dispose() {
    contenidoCtrl.dispose();
    explicacionCtrl.dispose();
    for (final o in opciones) {
      o.dispose();
    }
  }
}

class _OpcionData {
  final TextEditingController ctrl = TextEditingController();
  bool correcta = false;
  void dispose() => ctrl.dispose();
}

class _CrearEjercicioScreenState extends State<CrearEjercicioScreen> {
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final List<_QuestionData> _preguntas = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _preguntas.add(_crearPreguntaVacia());
  }

  _QuestionData _crearPreguntaVacia() {
    switch (widget.tipo) {
      case TipoEjercicio.trueFalse:
        final q = _QuestionData(numOpciones: 2);
        q.opciones[0].ctrl.text = 'Verdadero';
        q.opciones[1].ctrl.text = 'Falso';
        return q;
      case TipoEjercicio.respuestaCorta:
        return _QuestionData(numOpciones: 1);
      case TipoEjercicio.ordenar:
        return _QuestionData(numOpciones: 3);
      case TipoEjercicio.rellenar:
        return _QuestionData(numOpciones: 2);
      default:
        return _QuestionData(numOpciones: 4);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    for (final q in _preguntas) {
      q.dispose();
    }
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.tipo) {
      case TipoEjercicio.multipleChoice:
        return const Color(0xFF4DC130);
      case TipoEjercicio.trueFalse:
        return const Color(0xFFF6B55C);
      case TipoEjercicio.ordenar:
        return const Color(0xFF4DB0FF);
      case TipoEjercicio.rellenar:
        return const Color(0xFFFF606F);
      case TipoEjercicio.respuestaCorta:
        return const Color(0xFF9B51E0);
    }
  }

  IconData get _tipoIcon {
    switch (widget.tipo) {
      case TipoEjercicio.multipleChoice:
        return Icons.quiz_outlined;
      case TipoEjercicio.trueFalse:
        return Icons.check_circle_outline;
      case TipoEjercicio.ordenar:
        return Icons.swap_vert_rounded;
      case TipoEjercicio.rellenar:
        return Icons.text_fields_rounded;
      case TipoEjercicio.respuestaCorta:
        return Icons.short_text_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetadataCard(),
                      const SizedBox(height: 20),
                      ...List.generate(
                          _preguntas.length, (i) => _buildPreguntaCard(i)),
                      const SizedBox(height: 12),
                      _buildAddPreguntaButton(),
                      const SizedBox(height: 32),
                      _buildGuardarButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
              SvgPicture.asset('assets/images/logo.svg', width: 85, height: 42),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_tipoIcon, size: 16, color: _accentColor),
                const SizedBox(width: 6),
                Text(
                  widget.tipo.displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Crear Ejercicio',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Metadata (título + descripción) ─────────────────────────────────────────
  Widget _buildMetadataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información del ejercicio',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF676767))),
          const SizedBox(height: 16),
          _buildInputField(_tituloCtrl, 'Título', 'Ej: Cuestionario Lógico II'),
          const SizedBox(height: 14),
          _buildInputField(_descripcionCtrl, 'Descripción',
              'Describe brevemente el ejercicio...',
              maxLines: 3),
        ],
      ),
    );
  }

  // ── Pregunta Card ───────────────────────────────────────────────────────────
  Widget _buildPreguntaCard(int index) {
    final q = _preguntas[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text('${index + 1}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14))),
                ),
                const SizedBox(width: 12),
                Text('Pregunta ${index + 1}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const Spacer(),
                if (_preguntas.length > 1)
                  GestureDetector(
                    onTap: () => setState(() {
                      q.dispose();
                      _preguntas.removeAt(index);
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF606F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Color(0xFFFF606F)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputField(
                q.contenidoCtrl, 'Enunciado', 'Escribe la pregunta...',
                maxLines: 2),
            const SizedBox(height: 14),
            _buildInputField(q.explicacionCtrl, 'Explicación (opcional)',
                'Justificación de la respuesta...',
                maxLines: 2),
            const SizedBox(height: 18),
            _buildOpcionesSection(q),
          ],
        ),
      ),
    );
  }

  // ── Opciones según el tipo ──────────────────────────────────────────────────
  Widget _buildOpcionesSection(_QuestionData q) {
    switch (widget.tipo) {
      case TipoEjercicio.trueFalse:
        return _buildTrueFalseOpciones(q);
      case TipoEjercicio.respuestaCorta:
        return _buildRespuestaCortaOpciones(q);
      case TipoEjercicio.rellenar:
        return _buildRellenarOpciones(q);
      case TipoEjercicio.ordenar:
        return _buildOrdenarOpciones(q);
      default:
        return _buildMultipleChoiceOpciones(q);
    }
  }

  Widget _buildMultipleChoiceOpciones(_QuestionData q) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Opciones',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF676767))),
        const SizedBox(height: 4),
        const Text('Toca el círculo para marcar la correcta',
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: Color(0xFF999999))),
        const SizedBox(height: 12),
        ...List.generate(q.opciones.length, (i) {
          final o = q.opciones[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    for (var op in q.opciones) {
                      op.correcta = false;
                    }
                    o.correcta = true;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          o.correcta ? _accentColor : const Color(0xFFE8E8E8),
                      shape: BoxShape.circle,
                      boxShadow: o.correcta
                          ? [
                              BoxShadow(
                                  color: _accentColor.withValues(alpha: 0.3),
                                  blurRadius: 8)
                            ]
                          : [],
                    ),
                    child: Center(
                        child: Text(
                      i < letters.length ? letters[i] : '${i + 1}',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: o.correcta
                              ? Colors.white
                              : const Color(0xFF999999)),
                    )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: o.correcta
                              ? _accentColor.withValues(alpha: 0.5)
                              : const Color(0xFFEEEEEE)),
                    ),
                    child: TextField(
                      controller: o.ctrl,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        border: InputBorder.none,
                        hintText:
                            'Opción ${i < letters.length ? letters[i] : i + 1}',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalseOpciones(_QuestionData q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Respuesta correcta',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF676767))),
        const SizedBox(height: 12),
        Row(
          children: List.generate(2, (i) {
            final o = q.opciones[i];
            final label = i == 0 ? 'Verdadero' : 'Falso';
            final icon = i == 0 ? Icons.check_rounded : Icons.close_rounded;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i == 0 ? 8 : 0, left: i == 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() {
                    for (var op in q.opciones) {
                      op.correcta = false;
                    }
                    o.correcta = true;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: o.correcta
                          ? _accentColor.withValues(alpha: 0.12)
                          : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            o.correcta ? _accentColor : const Color(0xFFE0E0E0),
                        width: o.correcta ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 20,
                            color: o.correcta
                                ? _accentColor
                                : const Color(0xFF999999)),
                        const SizedBox(width: 8),
                        Text(label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: o.correcta
                                  ? _accentColor
                                  : const Color(0xFF999999),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRespuestaCortaOpciones(_QuestionData q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Respuesta esperada',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF676767))),
        const SizedBox(height: 12),
        _buildInputField(
            q.opciones[0].ctrl, '', 'Escribe la respuesta correcta...',
            maxLines: 2),
      ],
    );
  }

  Widget _buildOrdenarOpciones(_QuestionData q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Elementos a ordenar',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF676767))),
        const SizedBox(height: 4),
        const Text('Escríbelos en el orden correcto',
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: Color(0xFF999999))),
        const SizedBox(height: 12),
        ...List.generate(q.opciones.length, (i) {
          final o = q.opciones[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE8E8E8), shape: BoxShape.circle),
                  child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF999999)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE))),
                    child: TextField(
                      controller: o.ctrl,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        border: InputBorder.none,
                        hintText: 'Elemento ${i + 1}',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 13),
                      ),
                    ),
                  ),
                ),
                if (q.opciones.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Color(0xFFFF606F)),
                    onPressed: () => setState(() => q.opciones.removeAt(i)),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => q.opciones.add(_OpcionData())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Añadir elemento',
              style:
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildRellenarOpciones(_QuestionData q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Palabras para rellenar',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF676767))),
        const SizedBox(height: 4),
        const Text(
            'Añade las palabras en el orden que aparecen en los espacios',
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 11, color: Color(0xFF999999))),
        const SizedBox(height: 12),
        ...List.generate(q.opciones.length, (i) {
          final o = q.opciones[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Color(0xFFE8E8E8), shape: BoxShape.circle),
                  child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF999999)))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE))),
                    child: TextField(
                      controller: o.ctrl,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        border: InputBorder.none,
                        hintText: 'Palabra ${i + 1}',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB), fontSize: 13),
                      ),
                    ),
                  ),
                ),
                if (q.opciones.length > 1)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Color(0xFFFF606F)),
                    onPressed: () => setState(() => q.opciones.removeAt(i)),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => q.opciones.add(_OpcionData())),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Añadir palabra',
              style:
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── Botón agregar pregunta ──────────────────────────────────────────────────
  Widget _buildAddPreguntaButton() {
    return GestureDetector(
      onTap: () => setState(() => _preguntas.add(_crearPreguntaVacia())),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _accentColor.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: _accentColor, size: 22),
            const SizedBox(width: 8),
            Text('Añadir pregunta',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _accentColor,
                )),
          ],
        ),
      ),
    );
  }

  // ── Botón guardar ───────────────────────────────────────────────────────────
  Widget _buildGuardarButton() {
    return GestureDetector(
      onTap: _guardando ? null : _guardar,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_accentColor, _accentColor.withValues(alpha: 0.85)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: _accentColor.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_guardando)
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
            else ...[
              const Icon(Icons.save_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Text('Guardar Ejercicio',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // ── Input reutilizable ──────────────────────────────────────────────────────
  Widget _buildInputField(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF676767))),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // ── Lógica de guardado ──────────────────────────────────────────────────────
  Future<void> _guardar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      _showError('Ingresa un título para el ejercicio');
      return;
    }
    if (_preguntas.any((q) => q.contenidoCtrl.text.trim().isEmpty)) {
      _showError('Todas las preguntas deben tener un enunciado');
      return;
    }

    setState(() => _guardando = true);

    final preguntasInput = _preguntas.map((q) {
      final opcionesInput = q.opciones
          .map((o) {
            // Para ordenar y rellenar, todas son "correctas" por estar en la lista final
            bool esCorrecta = o.correcta;
            if (widget.tipo == TipoEjercicio.respuestaCorta ||
                widget.tipo == TipoEjercicio.ordenar ||
                widget.tipo == TipoEjercicio.rellenar) {
              esCorrecta = true;
            }
            return OpcionInput(
                contenido: o.ctrl.text.trim(), correcta: esCorrecta);
          })
          .where((o) => o.contenido.isNotEmpty)
          .toList();

      return PreguntaInput(
        contenido: q.contenidoCtrl.text.trim(),
        explicacion: q.explicacionCtrl.text.trim().isEmpty
            ? null
            : q.explicacionCtrl.text.trim(),
        opciones: opcionesInput,
      );
    }).toList();

    await EjerciciosController().crearEjercicioCompleto(
      idCapitulo: widget.idCapitulo,
      tipo: widget.tipo,
      titulo: _tituloCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? 'Ejercicio de ${widget.tipo.displayName}'
          : _descripcionCtrl.text.trim(),
      preguntasInput: preguntasInput,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text('Ejercicio de ${widget.tipo.displayName} creado',
                style: const TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        ),
      );
      Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.warning_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: const Color(0xFFFF606F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      ),
    );
  }
}
