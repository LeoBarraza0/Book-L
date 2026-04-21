import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/services/bookl_service.dart';
import '../widgets/seccion_editor_widget.dart';
import '../widgets/agregar_seccion_button.dart';
import '../controller/leccion_controller.dart';
import '../../domain/entities/leccion.dart';
import '../../domain/entities/capitulo.dart';

class LeccionEditarScreen extends StatefulWidget {
  final int? idLeccion;
  const LeccionEditarScreen({super.key, this.idLeccion});

  @override
  State<LeccionEditarScreen> createState() => _LeccionEditarScreenState();
}

class _LeccionEditarScreenState extends State<LeccionEditarScreen>
    with TickerProviderStateMixin {
  // ── Estado ─────────────────────────────────────────────────────────────────
  int _selectedTab = 0; // 0: Contenido, 1: Ejercicios, 2: Discusión
  final _tituloCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];
  final List<Capitulo> _capitulosEnMemoria = [];
  final List<int> _capitulosAEliminar = [];
  
  final _leccionCtrl = LeccionController();
  Leccion? _leccionActual;
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

    // Cargar lección existente si viene ID
    if (widget.idLeccion != null) {
      _leccionCtrl.seleccionarLeccion(widget.idLeccion!).then((_) {
        final l = _leccionCtrl.state.selected;
        if (l != null && mounted) {
          setState(() {
            _leccionActual = l;
            _tituloCtrl.text = l.nombre;
            
            _secciones.clear();
            if (l.contenido != null && l.contenido!.isNotEmpty) {
              for (final s in l.contenido!) {
                _secciones.add(SeccionData.fromJson(s));
              }
            } else {
              _secciones.add(SeccionData(titulo: 'Introducción'));
            }
            
            _capitulosEnMemoria.clear();
            _capitulosEnMemoria.addAll(_leccionCtrl.capitulosDeLeccion);
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

    // Sección inicial por defecto solo si no cargamos una existente
    if (widget.idLeccion == null) {
      _secciones.add(SeccionData(
        titulo: 'Introducción',
      ));
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _scrollCtrl.dispose();
    _headerAnimCtrl.dispose();
    _guardarAnimCtrl.dispose();
    for (final s in _secciones) {
      s.dispose();
    }
    super.dispose();
  }

  // ── Agregar nueva sección con scroll automático ────────────────────────────
  void _agregarSeccion() {
    setState(() {
      _secciones.add(SeccionData());
    });
    // Scroll al final tras el frame de construcción
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

  // ── Eliminar sección ──────────────────────────────────────────────────────
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
          // ── Contenido Principal ─────────────────────────────────────────
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // 1. Header con imagen verde
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: SlideTransition(
                    position: _headerSlideAnim,
                    child: _buildHeaderImage(context),
                  ),
                ),
              ),

              // 2. Cuerpo principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título editable + metadata
                      _buildTituloEditable(),
                      const SizedBox(height: 24),

                      // Tabs
                      _buildTabs(),
                      const SizedBox(height: 24),

                      // Contenido dinámico según pestaña
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _selectedTab == 0
                            ? Container(
                                key: const ValueKey(0),
                                child: _buildContenidoEditor(),
                              )
                            : _selectedTab == 1
                                ? Container(
                                    key: const ValueKey(1),
                                    child: _buildProximamente('Ejercicios'),
                                  )
                                : Container(
                                    key: const ValueKey(2),
                                    child: _buildProximamente('Discusión'),
                                  ),
                      ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Navigation Bar flotante ────────────────────────────
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

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          // Fondo verde
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

          // Overlay semitransparente con patrón de edición
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

          // Badge "Modo Edición"
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

          // Botones de navegación
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

  /// Título editable inline + metadata del autor.
  Widget _buildTituloEditable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Caja de título
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  controller: _tituloCtrl,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF363333),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Título de la lección...',
                  ),
                ),
              ),
              const Icon(Icons.edit, size: 16, color: Color(0xFFAAAAAA)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Metadata: avatar + nombre + badge + rating dinámicos
        Builder(
          builder: (context) {
            final idUsuario = _leccionActual?.idUsuarioFk ?? AppSession().usuarioId;
            final usuario = idUsuario != null
                ? BooklService().usuarios.cast<dynamic>().firstWhere(
                    (u) => u.idUsuario == idUsuario,
                    orElse: () => null,
                  )
                : null;
            final nombreAutor = usuario?.nombreCompleto ?? AppSession().nombreCompleto ?? '---';
            final rolAutor = usuario?.rol ?? 'Estudiante';
            final ratingText = _leccionActual != null && _leccionActual!.rating > 0
                ? _leccionActual!.rating.toStringAsFixed(1)
                : '---';
            return Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF60A144),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  nombreAutor,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF79AC63),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rolAutor,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                const SizedBox(width: 3),
                Text(
                  ratingText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Tabs idénticos a leccion_detail_screen en diseño.
  Widget _buildTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          _buildTabItem('Contenido', 0),
          _buildTabItem('Ejercicios', 1),
          _buildTabItem('Discusión', 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4DC130) : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Vista principal del editor de contenido.
  Widget _buildContenidoEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Lista de secciones ────────────────────────────────────────
        ...List.generate(_secciones.length, (i) {
          return SeccionEditorWidget(
            key: ValueKey(_secciones[i].hashCode),
            data: _secciones[i],
            index: i,
            onEliminar: () => _eliminarSeccion(i),
          );
        }),

        const SizedBox(height: 8),

        // ── Botón agregar sección ────────────────────────────────────
        AgregarSeccionButton(onTap: _agregarSeccion),

        const SizedBox(height: 32),

        // ─── Capítulos ──────────────────────────────────────────────────────────
        const Text(
          'Capítulos',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF363333),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_capitulosEnMemoria.length, (i) {
          return _buildCapituloItemEditable(i, _capitulosEnMemoria[i]);
        }),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _irACrearCapitulo,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF4DC130), size: 20),
            label: const Text(
              'Añadir Capítulo',
              style: TextStyle(
                color: Color(0xFF4DC130),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: const Color(0xFF4DC130).withOpacity(0.1),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Botón Guardar ─────────────────────────────────────────────
        _buildGuardarButton(),
      ],
    );
  }

  /// Pantalla vacía/placeholder para tabs no implementados en esta pantalla.
  Widget _buildProximamente(String tab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              tab == 'Ejercicios' ? Icons.quiz_outlined : Icons.forum_outlined,
              size: 54,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'La sección de $tab se muestra\ndesde la vista del estudiante.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón "Guardar" animado al fondo del contenido.
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
    final nombre = _tituloCtrl.text.trim();
    if (nombre.isEmpty) return;
    setState(() => _guardando = true);
    try {
      if (_leccionActual != null) {
        // 1. Guardar cambios básicos de la lección
        await _leccionCtrl.editarLeccion(
          _leccionActual!.copyWith(
            nombre: nombre,
            contenido: _secciones.map((s) => s.toJson()).toList(),
          ),
        );
        
        // 2. Sincronizar Capítulos eliminados
        for (final idCap in _capitulosAEliminar) {
          await _leccionCtrl.eliminarCapitulo(idCap, _leccionActual!.idLeccion);
        }
        
        // 3. Sincronizar Capítulos (Agregar nuevos o Editar existentes)
        for (final cap in _capitulosEnMemoria) {
          final existe = _leccionCtrl.capitulosDeLeccion.any((c) => c.idCapitulo == cap.idCapitulo);
          if (!existe) {
             await _leccionCtrl.agregarCapitulo(
               idLeccion: _leccionActual!.idLeccion,
               nombre: cap.nombre,
               contenido: cap.contenido,
               tiempoTotal: cap.tiempoTotal,
             );
          } else {
             await _leccionCtrl.editarCapitulo(cap);
          }
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Lección guardada exitosamente',
                  style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: const Color(0xFF4DC130),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  // ─── Capítulos Componentes Estandarizados ─────────────────────────────────
  Widget _buildCapituloItemEditable(int index, Capitulo capitulo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFBDBDBD),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitulo.nombre.isEmpty ? 'Capítulo ${index + 1}' : capitulo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF676767)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuracion(capitulo.tiempoTotal),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF676767),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          GestureDetector(
            onTap: () {
               Navigator.pushNamed(context, '/capitulo_editar_screen', arguments: capitulo.idCapitulo);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 20, color: Color(0xFF676767)),
            ),
          ),
          GestureDetector(
            onTap: () {
               setState(() {
                 final removed = _capitulosEnMemoria.removeAt(index);
                 if (_leccionCtrl.capitulosDeLeccion.any((c) => c.idCapitulo == removed.idCapitulo)) {
                    _capitulosAEliminar.add(removed.idCapitulo);
                 }
               });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline,
                  size: 20, color: Color(0xFFD63030)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuracion(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final mins = segundos ~/ 60;
    if (mins < 60) return '$mins min';
    final horas = mins ~/ 60;
    final resto = mins % 60;
    return resto == 0 ? '${horas}h' : '${horas}h ${resto}min';
  }

  Future<void> _irACrearCapitulo() async {
    final resultado = await Navigator.pushNamed(context, '/crear_capitulo');
    if (resultado != null && resultado is Capitulo) {
      if (mounted) {
        setState(() => _capitulosEnMemoria.add(resultado));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón Guardar con animación de press propia
// ─────────────────────────────────────────────────────────────────────────────
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
