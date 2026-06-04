import 'dart:io';
import 'package:book_l/core/utils/feedback_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/shared/widgets/header_background_image.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';

import 'package:book_l/shared/widgets/seccion_editor_widget.dart';
import '../widgets/agregar_seccion_button.dart';
import '../widgets/material_editor_tile.dart';
import '../controller/leccion_controller.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/domain/models/material_educativo.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';

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

  final Map<String, Uint8List> _pdfBytesCache = {};

  final List<SeccionData> _secciones = [];
  final List<Capitulo> _capitulosEnMemoria = [];
  final List<int> _capitulosAEliminar = [];
  final List<MaterialEducativo> _materialesEnMemoria = [];
  final List<int> _materialesAEliminar = [];

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
      _leccionCtrl.prepararLeccion(widget.idLeccion!);
      final cachedL = _leccionCtrl.state.selected;
      if (cachedL != null) {
        _leccionActual = cachedL;
        _tituloCtrl.text = cachedL.nombre;

        _secciones.clear();
        if (cachedL.contenido != null && cachedL.contenido!.isNotEmpty) {
          for (final s in cachedL.contenido!) {
            _secciones.add(SeccionData.fromJson(s));
          }
        } else {
          _secciones.add(SeccionData(titulo: 'Introducción'));
        }

        _capitulosEnMemoria.clear();
        _capitulosEnMemoria.addAll(_leccionCtrl.capitulosDeLeccion);

        // Cargar materiales existentes
        _materialesEnMemoria.clear();
        _materialesEnMemoria.addAll(
          _leccionCtrl.materialesDeLeccion(cachedL.idLeccion),
        );
      }

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

            // Cargar materiales existentes
            _materialesEnMemoria.clear();
            _materialesEnMemoria.addAll(
              _leccionCtrl.materialesDeLeccion(l.idLeccion),
            );
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
          // Fondo verde o imagen subida
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: HeaderBackgroundImage(
                imagenUrl: _leccionActual?.imagenUrl,
                fallbackAsset: 'assets/images/green_bg.png',
                fallbackColor: const Color(0xFF4DC130),
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
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
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
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
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
                  Row(
                    children: [
                      _buildCircularIconButton(
                          Icons.camera_alt_rounded, _cambiarImagen),
                      const SizedBox(width: 10),
                      _buildCircularIconButton(
                        Icons.delete_rounded,
                        _eliminarLeccion,
                        bgColor: Colors.red.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap,
      {Color? bgColor, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: bgColor ?? const Color(0xFF6BCA54).withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
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
            final idUsuario =
                _leccionActual?.idUsuarioFk ?? AppSession().usuarioId;
            final usuario = idUsuario != null
                ? _leccionCtrl.getCreadorSync(idUsuario)
                : null;
            final nombreAutor =
                usuario?.nombreCompleto ?? AppSession().nombreCompleto ?? '---';
            final rolAutor = usuario?.rol ?? 'Estudiante';
            final ratingText =
                _leccionActual != null && _leccionActual!.rating > 0
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
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 18),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              backgroundColor: const Color(0xFF4DC130).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ─── Material Relacionado ───────────────────────────────────────────────
        const Text(
          'Material Relacionado',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF363333),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_materialesEnMemoria.length, (i) {
          return MaterialEditorTile(
            material: _materialesEnMemoria[i],
            onEditar: () => _editarMaterial(i),
            onEliminar: () {
              setState(() {
                final removed = _materialesEnMemoria.removeAt(i);
                if (removed.idMaterial > 0) {
                  _materialesAEliminar.add(removed.idMaterial);
                }
              });
            },
          );
        }),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _mostrarModalAgregarMaterial,
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Color(0xFF4DC130), size: 20),
            label: const Text(
              'Añadir Material',
              style: TextStyle(
                color: Color(0xFF4DC130),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: const Color(0xFF4DC130).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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

  Future<void> _cambiarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && _leccionActual != null) {
      setState(() {
        _leccionActual = _leccionActual!.copyWith(imagenUrl: picked.path);
      });
    }
  }

  Future<void> _eliminarLeccion() async {
    final confirmar = await FeedbackUtils.showConfirmDialog(
      context: context,
      title: 'Eliminar Lección',
      content:
          '¿Estás seguro de que deseas eliminar esta lección? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmar == true && _leccionActual != null) {
      _leccionCtrl.eliminarLeccion(_leccionActual!.idLeccion);
      if (mounted) {
        FeedbackUtils.showSuccessSnackBar(
            context, 'Lección eliminada correctamente.');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _guardar() async {
    final nombre = _tituloCtrl.text.trim();
    if (nombre.isEmpty) return;
    setState(() => _guardando = true);
    try {
      // Subir media de secciones si es local
      for (var sec in _secciones) {
        if (sec.tieneImagen && sec.imagenPath != null && !sec.imagenPath!.startsWith('http') && !sec.imagenPath!.startsWith('assets/')) {
          final url = await SupabaseClientHelper.uploadFile('bookl-medias', sec.imagenPath!);
          if (url != null) sec.imagenPath = url;
        }
        if (sec.tieneVideo && sec.videoPath != null && !sec.videoPath!.startsWith('http') && !sec.videoPath!.startsWith('assets/')) {
          final url = await SupabaseClientHelper.uploadFile('bookl-medias', sec.videoPath!);
          if (url != null) sec.videoPath = url;
        }
      }

      // Subir url de materiales si es local
      for (int i = 0; i < _materialesEnMemoria.length; i++) {
        final mat = _materialesEnMemoria[i];
        if (mat.url != null && !mat.url!.startsWith('http') && !mat.url!.startsWith('assets/')) {
          String? url;
          if (kIsWeb && _pdfBytesCache.containsKey(mat.url!)) {
            final bytes = _pdfBytesCache[mat.url!];
            url = await SupabaseClientHelper.uploadBytes('bookl-medias', bytes!, mat.url!);
          } else {
            url = await SupabaseClientHelper.uploadFile('bookl-medias', mat.url!);
          }
          if (url != null) {
            _materialesEnMemoria[i] = mat.copyWith(url: url);
          }
        }
      }

      if (_leccionActual != null) {
        // 1. Guardar cambios básicos de la lección
        await _leccionCtrl.editarLeccion(
          _leccionActual!.copyWith(
            nombre: nombre,
            contenido: _secciones.map((s) => s.toJson()).toList(),
            imagenUrl: _leccionActual!.imagenUrl,
          ),
        );

        // 2. Sincronizar Capítulos eliminados
        for (final idCap in _capitulosAEliminar) {
          await _leccionCtrl.eliminarCapitulo(idCap, _leccionActual!.idLeccion);
        }

        // 3. Sincronizar Capítulos (Agregar nuevos o Editar existentes)
        for (final cap in _capitulosEnMemoria) {
          final existe = _leccionCtrl.capitulosDeLeccion
              .any((c) => c.idCapitulo == cap.idCapitulo);
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

        // 4. Sincronizar Materiales eliminados
        for (final idMat in _materialesAEliminar) {
          _leccionCtrl.eliminarMaterial(idMat);
        }

        // 5. Sincronizar Materiales (Agregar nuevos o Editar existentes)
        for (final mat in _materialesEnMemoria) {
          if (mat.idMaterial <= 0) {
            _leccionCtrl.agregarMaterial(
              idLeccion: _leccionActual!.idLeccion,
              nombre: mat.nombre,
              tipo: mat.tipo,
              url: mat.url,
              descripcion: mat.descripcion,
              tamanoBytes: mat.tamanoBytes,
            );
          } else {
            _leccionCtrl.editarMaterial(mat.copyWith(
              idLeccionFk: _leccionActual!.idLeccion,
            ));
          }
        }
      }
      if (mounted) {
        FeedbackUtils.showSuccessSnackBar(
            context, 'Lección guardada exitosamente');
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
                  capitulo.nombre.isEmpty
                      ? 'Capítulo ${index + 1}'
                      : capitulo.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: Color(0xFF676767)),
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
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/editar_capitulo',
                arguments: capitulo.idCapitulo,
              );
              if (result != null && result is Capitulo) {
                setState(() {
                  _capitulosEnMemoria[index] = result;
                });
              }
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
                if (_leccionCtrl.capitulosDeLeccion
                    .any((c) => c.idCapitulo == removed.idCapitulo)) {
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

  // ─── Material Relacionado ─────────────────────────────────────────────────

  void _mostrarModalAgregarMaterial() {
    _showMaterialDialog(null, null);
  }

  void _editarMaterial(int index) {
    _showMaterialDialog(_materialesEnMemoria[index], index);
  }

  void _showMaterialDialog(MaterialEducativo? existing, int? index) {
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final descCtrl = TextEditingController(text: existing?.descripcion ?? '');
    final urlCtrl = TextEditingController(text: existing?.url ?? '');
    String tipoSeleccionado = existing?.tipo ?? 'pdf';
    String? filePath = existing?.url;
    int tamano = existing?.tamanoBytes ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      existing != null ? 'Editar Material' : 'Nuevo Material',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF363333),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildTipoChip(
                            'PDF',
                            'pdf',
                            tipoSeleccionado,
                            const Color(0xFF4DC130),
                            (t) => setModalState(() => tipoSeleccionado = t)),
                        const SizedBox(width: 8),
                        _buildTipoChip(
                            'Video',
                            'video',
                            tipoSeleccionado,
                            const Color(0xFFFF606F),
                            (t) => setModalState(() => tipoSeleccionado = t)),
                        const SizedBox(width: 8),
                        _buildTipoChip(
                            'Enlace',
                            'enlace',
                            tipoSeleccionado,
                            const Color(0xFF4A90D9),
                            (t) => setModalState(() => tipoSeleccionado = t)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nombreCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del material',
                        labelStyle:
                            const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        labelStyle:
                            const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (tipoSeleccionado == 'enlace' ||
                        tipoSeleccionado == 'video') ...[
                      TextField(
                        controller: urlCtrl,
                        decoration: InputDecoration(
                          labelText: tipoSeleccionado == 'video'
                              ? 'URL del video (ej. YouTube, o ignora para subir archivo)'
                              : 'URL del enlace',
                          labelStyle: const TextStyle(
                              fontFamily: 'Inter', fontSize: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          prefixIcon: const Icon(Icons.link),
                        ),
                        onChanged: (val) {
                          if (val.trim().isNotEmpty && filePath != null) {
                            setModalState(() => filePath = null);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (tipoSeleccionado != 'enlace') ...[
                      if (tipoSeleccionado == 'video') ...[
                        const Text('O selecciona un archivo local:',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.black54)),
                        const SizedBox(height: 8),
                      ],
                      GestureDetector(
                        onTap: () async {
                          if (tipoSeleccionado == 'pdf') {
                            try {
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                                withData: kIsWeb,
                              );
                              if (result != null) {
                                final single = result.files.single;
                                setModalState(() {
                                  if (kIsWeb && single.bytes != null) {
                                    filePath = single.name;
                                    tamano = single.size;
                                    _pdfBytesCache[single.name] = single.bytes!;
                                  } else {
                                    if (single.path != null) {
                                      filePath = single.path;
                                      tamano = single.size;
                                    }
                                  }
                                  if (nombreCtrl.text.isEmpty) {
                                    nombreCtrl.text = single.name;
                                  }
                                });
                              }
                            } catch (_) {}
                          } else {
                            final picker = ImagePicker();
                            final vid = await picker.pickVideo(
                                source: ImageSource.gallery);
                            if (vid != null) {
                              final file = File(vid.path);
                              setModalState(() {
                                filePath = vid.path;
                                tamano = file.lengthSync();
                                if (nombreCtrl.text.isEmpty) {
                                  nombreCtrl.text = vid.name;
                                }
                              });
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDDDDDD)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                filePath != null
                                    ? Icons.check_circle
                                    : Icons.upload_file,
                                color: filePath != null
                                    ? const Color(0xFF4DC130)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  filePath != null
                                      ? filePath!.split('/').last
                                      : 'Seleccionar archivo ${tipoSeleccionado.toUpperCase()}...',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: filePath != null
                                        ? Colors.black87
                                        : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nombreCtrl.text.trim().isEmpty) return;
                          final mat = MaterialEducativo(
                            idMaterial: existing?.idMaterial ?? 0,
                            idLeccionFk: _leccionActual?.idLeccion ?? 0,
                            nombre: nombreCtrl.text.trim(),
                            tipo: tipoSeleccionado,
                            url: (tipoSeleccionado == 'enlace' ||
                                    urlCtrl.text.trim().isNotEmpty)
                                ? urlCtrl.text.trim()
                                : filePath,
                            descripcion: descCtrl.text.trim().isEmpty
                                ? null
                                : descCtrl.text.trim(),
                            tamanoBytes: tamano,
                          );

                          // Asegurarnos de que el material de tipo video tenga protocolo http/https
                          MaterialEducativo finalMat = mat;
                          if (mat.tipo == 'video' || mat.tipo == 'enlace') {
                            if (mat.url != null && mat.url!.isNotEmpty && !mat.url!.startsWith('http')) {
                              finalMat = mat.copyWith(url: 'https://${mat.url}');
                            }
                          }

                          setState(() {
                            if (index != null) {
                              _materialesEnMemoria[index] = finalMat;
                            } else {
                              _materialesEnMemoria.add(finalMat);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DC130),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          existing != null
                              ? 'Guardar cambios'
                              : 'Agregar material',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTipoChip(String label, String tipo, String selected, Color color,
      ValueChanged<String> onTap) {
    final isSelected = tipo == selected;
    return GestureDetector(
      onTap: () => onTap(tipo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: color.withValues(alpha: isSelected ? 1.0 : 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
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
                color: const Color(0xFF4DC130).withValues(alpha: 0.40),
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
