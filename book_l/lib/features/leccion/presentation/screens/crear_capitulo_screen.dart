import 'package:flutter/material.dart';
import 'package:book_l/shared/domain/models/capitulo_model.dart';
import 'package:book_l/shared/domain/models/ejercicio_model.dart';
import 'package:book_l/shared/data/local_db_service.dart';
import '../widgets/seccion_editor_widget.dart';
import '../widgets/agregar_seccion_button.dart';

class CrearCapituloScreen extends StatefulWidget {
  const CrearCapituloScreen({super.key});

  @override
  State<CrearCapituloScreen> createState() => _CrearCapituloScreenState();
}

class _CrearCapituloScreenState extends State<CrearCapituloScreen>
    with TickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];
  final List<EjercicioModel> _ejercicios = [];

  // Animaciones
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;
  late AnimationController _guardarAnimCtrl;
  late Animation<double> _guardarScaleAnim;

  @override
  void initState() {
    super.initState();

    _secciones.add(SeccionData(titulo: 'Contenido'));

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

                      // Secciones de contenido
                      _buildSeccionLabel('Contenido del capítulo'),
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

                      // Ejercicio
                      _buildSeccionLabel('Ejercicios del capítulo'),
                      const SizedBox(height: 12),
                      ..._ejercicios
                          .map((ex) => _buildEjercicioItem(ex))
                          .toList(),
                      const SizedBox(height: 8),
                      Center(
                        child: AgregarSeccionButton(
                          titulo: 'Añadir ejercicio',
                          onTap: () => _mostrarOpcionesPrueba(context),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Botón guardar centrado
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

          // Badge "Nuevo Capítulo"
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
                    Icon(Icons.menu_book_rounded,
                        size: 16, color: Color(0xFF4DC130)),
                    SizedBox(width: 6),
                    Text(
                      'Nuevo Capítulo',
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
                hintText: 'Nombre del capítulo...',
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

  Widget _buildGuardarButton() {
    return ScaleTransition(
      scale: _guardarScaleAnim,
      child: Center(
        child: SizedBox(
          width: 220,
          child: _GuardarButton(onTap: _guardarCapitulo),
        ),
      ),
    );
  }

  void _guardarCapitulo() {
    final nombre = _nombreCtrl.text.trim();
    final nuevoCapitulo = CapituloModel(
      id: LocalDbService.instance.generateId(),
      nombre: nombre.isEmpty ? 'Capítulo sin nombre' : nombre,
      ejercicios: List.from(_ejercicios),
      secciones: _secciones
          .map((s) => {
                'nombre': s.tituloCtrl.text,
                'contenido': s.cuerpoCtrl.document.toPlainText(),
              })
          .toList(),
    );
    // Retorna el capítulo a la pantalla anterior
    Navigator.pop(context, nuevoCapitulo);
  }

  Widget _buildEjercicioItem(EjercicioModel ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(
            ex.tipo == 'teorico' ? Icons.quiz_outlined : Icons.code,
            color: ex.tipo == 'teorico'
                ? const Color(0xFF4DC130)
                : const Color(0xFFFF606F),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ex.pregunta,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.redAccent),
            onPressed: () => setState(() => _ejercicios.remove(ex)),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesPrueba(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Agregar Ejercicio',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué tipo de ejercicio deseas agregar?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF676767),
                ),
              ),
              const SizedBox(height: 24),
              _buildOpcionBottomSheet(
                icon: Icons.quiz_outlined,
                title: 'Ejercicio Teórico',
                subtitle: 'Opción múltiple, completar, verdadero/falso',
                color: const Color(0xFF4DC130),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.pushNamed(
                      context, '/crear_ejercicio_teorico');
                  if (result != null && result is List<EjercicioModel>) {
                    setState(() => _ejercicios.addAll(result));
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildOpcionBottomSheet(
                icon: Icons.code,
                title: 'Ejercicio Práctico',
                subtitle: 'Escribir y validar código',
                color: const Color(0xFFFF606F),
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await Navigator.pushNamed(
                      context, '/crear_ejercicio_practico');
                  if (result != null && result is List<EjercicioModel>) {
                    setState(() => _ejercicios.addAll(result));
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcionBottomSheet({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Color(0xFF676767),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
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
              Icon(Icons.check_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Agregar capítulo',
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
