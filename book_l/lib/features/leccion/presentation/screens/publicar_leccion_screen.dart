import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:book_l/shared/data/leccion_repository.dart';
import 'package:book_l/shared/domain/models/leccion_model.dart';
import 'package:book_l/shared/domain/models/capitulo_model.dart';
import 'package:book_l/core/services/bookl_service.dart';
import '../widgets/agregar_seccion_button.dart';
import '../widgets/seccion_editor_widget.dart';

class PublicarLeccionScreen extends StatefulWidget {
  const PublicarLeccionScreen({super.key});

  @override
  State<PublicarLeccionScreen> createState() => _PublicarLeccionScreenState();
}

class _PublicarLeccionScreenState extends State<PublicarLeccionScreen>
    with TickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];
  final List<CapituloModel> _capitulosEnMemoria = [];
  bool _guardando = false;

  // Animaciones
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  late AnimationController _guardarAnimCtrl;
  late Animation<double> _guardarScaleAnim;

  @override
  void initState() {
    super.initState();

    // Sección inicial por defecto
    _secciones.add(SeccionData(titulo: 'Descripción'));

    // Header: fade + slide desde arriba
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFadeAnim = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut));

    // Botón Guardar: pulso al entrar
    _guardarAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _guardarScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _guardarAnimCtrl, curve: Curves.easeOutBack),
    );

    _headerAnimCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _guardarAnimCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _scrollCtrl.dispose();
    _headerAnimCtrl.dispose();
    _guardarAnimCtrl.dispose();
    for (final s in _secciones) {
      s.dispose();
    }
    super.dispose();
  }

  void _agregarSeccion() {
    setState(() => _secciones.add(SeccionData()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _eliminarSeccion(int index) {
    setState(() {
      _secciones[index].dispose();
      _secciones.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // Header verde
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: SlideTransition(
                    position: _headerSlideAnim,
                    child: _buildHeader(context),
                  ),
                ),
              ),

              // Cuerpo
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre editable inline
                      _buildNombreEditable(),
                      const SizedBox(height: 28),

                      // Secciones — material de apoyo/descripción
                      _buildSeccionLabel('Material de apoyo'),
                      const SizedBox(height: 12),
                      ...List.generate(_secciones.length, (i) {
                        return SeccionEditorWidget(
                          key: ValueKey(_secciones[i].hashCode),
                          data: _secciones[i],
                          index: i,
                          onEliminar: () => _eliminarSeccion(i),
                        );
                      }),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AgregarSeccionButton(onTap: _agregarSeccion),
                      ),

                      const SizedBox(height: 28),

                      // Sección capítulos
                      _buildSeccionLabel('Capítulos'),
                      const SizedBox(height: 12),
                      ..._capitulosEnMemoria.asMap().entries.map(
                            (e) => _buildCapituloChip(e.key, e.value),
                          ),
                      const SizedBox(height: 8),

                      // Botón centrado "Añadir Capítulo"
                      Center(
                        child: AgregarSeccionButton(
                          titulo: 'Añadir Capítulo',
                          onTap: _irACrearCapitulo,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Botón Guardar
                      _buildGuardarButton(),

                      const SizedBox(height: 120),
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

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Image.asset(
                'assets/images/green_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF4DC130)),
              ),
            ),
          ),

          // Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Logo centrado
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/logo_white.svg',
                width: 80,
                height: 35,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Badge "Nueva Lección"
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 16, color: Color(0xFF4DC130)),
                    SizedBox(width: 6),
                    Text(
                      'Nueva Lección',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3AA820),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botón back
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _buildCircularIconButton(
                Icons.arrow_back_rounded,
                () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF6BCA54).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // ─── Nombre editable inline ─────────────────────────────────────────────────
  Widget _buildNombreEditable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nombreCtrl,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF363333),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Nombre de la lección...',
                hintStyle: TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          const Icon(Icons.edit, size: 16, color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  // ─── Label de sección ───────────────────────────────────────────────────────
  Widget _buildSeccionLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF363333),
      ),
    );
  }

  // ─── Chip de capítulo añadido ────────────────────────────────────────────────
  Widget _buildCapituloChip(int index, CapituloModel capitulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              capitulo.nombre.isEmpty
                  ? 'Capítulo ${index + 1}'
                  : capitulo.nombre,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _capitulosEnMemoria.removeAt(index)),
            child: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  // ─── Navegar a crear capítulo ────────────────────────────────────────────────
  Future<void> _irACrearCapitulo() async {
    final resultado = await Navigator.pushNamed(context, '/crear_capitulo');
    if (resultado != null && resultado is CapituloModel) {
      setState(() => _capitulosEnMemoria.add(resultado));
    }
  }

  // ─── Botón Guardar ───────────────────────────────────────────────────────────
  Widget _buildGuardarButton() {
    return ScaleTransition(
      scale: _guardarScaleAnim,
      child: Center(
        child: SizedBox(
          width: 220,
          child: _GuardarButton(
            onTap: _guardando ? null : _guardarLeccion,
          ),
        ),
      ),
    );
  }

  // ─── Lógica de guardado ──────────────────────────────────────────────────────
  Future<void> _guardarLeccion() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de la lección es obligatorio'),
          backgroundColor: Color(0xFFFF606F),
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      // Construir el contenido de secciones como texto plano
      final contenido = _secciones
          .map((s) =>
              '${s.tituloCtrl.text}: ${s.cuerpoCtrl.document.toPlainText().trim()}')
          .where((s) => s.trim().isNotEmpty)
          .join('\n');

      final nuevaLeccion = LeccionModel(
        id: BooklService().generateId(),
        nombre: nombre,
        contenido: contenido,
        tipo: 'teorica',
        capitulos: _capitulosEnMemoria,
      );

      await LeccionRepository.instance.addLeccion(nuevaLeccion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Lección guardada exitosamente',
                style:
                    TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ]),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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

// ─── Botón Guardar animado ────────────────────────────────────────────────────
class _GuardarButton extends StatefulWidget {
  final VoidCallback? onTap;
  const _GuardarButton({required this.onTap});

  @override
  State<_GuardarButton> createState() => _GuardarButtonState();
}

class _GuardarButtonState extends State<_GuardarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF48C634), Color(0xFF3AAA26)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4DC130).withOpacity(0.40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Guardar lección',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
