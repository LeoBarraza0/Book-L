import 'package:flutter/material.dart';
import '../../../../shared/widgets/seccion_editor_widget.dart';
import '../widgets/agregar_seccion_button.dart';
import '../controller/leccion_controller.dart';
import '../../domain/entities/capitulo.dart';

class CapituloEditarScreen extends StatefulWidget {
  /// ID del capítulo a editar. Si es null se crea uno nuevo.
  final int? idCapitulo;
  /// ID de la lección padre (requerido si se crea un capítulo nuevo).
  final int? idLeccion;

  const CapituloEditarScreen({super.key, this.idCapitulo, this.idLeccion});

  @override
  State<CapituloEditarScreen> createState() => _CapituloEditarScreenState();
}

class _CapituloEditarScreenState extends State<CapituloEditarScreen>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];
  final _nombreCtrl = TextEditingController();
  final _ctrl = LeccionController();
  Capitulo? _capituloActual;
  bool _guardando = false;

  // Animación de entrada del header
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  // Animación del botón Guardar
  late AnimationController _guardarAnimCtrl;
  late Animation<double> _guardarScaleAnim;

  @override
  void initState() {
    super.initState();

    // Cargar datos del capítulo si viene un ID
    if (widget.idCapitulo != null) {
      _ctrl.obtenerCapitulo(widget.idCapitulo!).then((cap) {
        if (cap != null && mounted) {
          setState(() {
            _capituloActual = cap;
            _nombreCtrl.text = cap.nombre;

            _secciones.clear();
            if (cap.contenido != null && cap.contenido!.isNotEmpty) {
              for (final s in cap.contenido!) {
                _secciones.add(SeccionData.fromJson(s));
              }
            } else {
              _secciones.add(SeccionData(titulo: 'Introducción'));
            }
          });
        }
      });
    }

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

    // Secciones iniciales si es nuevo
    if (widget.idCapitulo == null) {
      _secciones.add(SeccionData(
        titulo: 'Introducción',
      ));
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _nombreCtrl.dispose();
    _headerAnimCtrl.dispose();
    _guardarAnimCtrl.dispose();
    for (final s in _secciones) {
      s.dispose();
    }
    super.dispose();
  }

  void _agregarSeccion() {
    setState(() {
      _secciones.add(SeccionData());
    });
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
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: SlideTransition(
                    position: _headerSlideAnim,
                    child: _buildHeaderImage(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNombreCapitulo(),
                      const SizedBox(height: 24),
                      _buildContenidoEditor(),
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

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Transform.scale(
                scale: 1.15,
                child: Image.asset(
                  'assets/images/green_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF4DC130)),
                ),
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
                      Colors.black.withOpacity(0.15),
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_note_rounded,
                        size: 16, color: Color(0xFF4DC130)),
                    SizedBox(width: 6),
                    Text(
                      'Modo Edición',
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularIconButton(
                    Icons.arrow_back_rounded,
                    () => Navigator.pop(context),
                  ),
                  _buildCircularIconButton(Icons.share_rounded, () {}),
                ],
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

  Widget _buildNombreCapitulo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nombre del Capítulo',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF676767),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nombreCtrl,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF363333),
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Introducción a la algoritmia',
              hintStyle: TextStyle(color: Colors.black.withOpacity(0.15)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
        const SizedBox(height: 36),
        _buildAgregarPruebaButton(),
        const SizedBox(height: 36),
        _buildGuardarButton(),
      ],
    );
  }

  Widget _buildAgregarPruebaButton() {
    return AgregarSeccionButton(
      titulo: 'Agregar prueba',
      onTap: () {
        _mostrarOpcionesPrueba(context);
      },
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
                'Agregar Prueba',
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
                title: 'Crear Ejercicio Teórico',
                subtitle: 'Opción múltiple, completar, verdadero/falso',
                color: const Color(0xFF4DC130),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/crear_ejercicio_teorico');
                },
              ),
              const SizedBox(height: 12),
              _buildOpcionBottomSheet(
                icon: Icons.code,
                title: 'Crear Ejercicio Práctico',
                subtitle: 'Escribir y validar código',
                color: const Color(0xFFFF606F),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/crear_ejercicio_practico');
                },
              ),
              const SizedBox(height: 12),
              _buildOpcionBottomSheet(
                icon: Icons.file_present_rounded,
                title: 'Adjuntar Ejercicio Existente',
                subtitle: 'Seleccionar del banco de ejercicios',
                color: const Color(0xFFF6B55C),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abriendo banco de ejercicios...'),
                    ),
                  );
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

  Widget _buildGuardarButton() {
    return ScaleTransition(
      scale: _guardarScaleAnim,
      child: SizedBox(
        width: double.infinity,
        child: _GuardarButton(
          onTap: _guardando ? null : _guardar,
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim().isNotEmpty
        ? _nombreCtrl.text.trim()
        : (_capituloActual?.nombre ?? 'Capítulo sin nombre');

    setState(() => _guardando = true);
    try {
      if (_capituloActual != null) {
        // Edición
        final capituloEditado = _capituloActual!.copyWith(
          nombre: nombre,
          contenido: _secciones.map((s) => s.toJson()).toList(),
        );
        await _ctrl.editarCapitulo(capituloEditado);
        _capituloActual = capituloEditado;
      } else {
        // Creación nueva
        final idLeccion = widget.idLeccion ?? 1;
        final idNuevo = await _ctrl.agregarCapitulo(
          idLeccion: idLeccion,
          nombre: nombre,
          contenido: _secciones.map((s) => s.toJson()).toList(),
        );
        _capituloActual = (await _ctrl.obtenerCapitulo(idNuevo))!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Capítulo guardado exitosamente',
                  style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, _capituloActual);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}

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
            borderRadius: BorderRadius.circular(12),
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
                'Guardar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
