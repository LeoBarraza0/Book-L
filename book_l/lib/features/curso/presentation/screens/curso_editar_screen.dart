import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../leccion/presentation/screens/leccion_editar_screen.dart';
import '../../../../shared/widgets/seccion_editor_widget.dart';
import '../../../leccion/presentation/widgets/agregar_seccion_button.dart';

import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../leccion/domain/entities/leccion.dart';
import '../../domain/entities/curso.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CursoEditarScreen
// ─────────────────────────────────────────────────────────────────────────────
class CursoEditarScreen extends StatefulWidget {
  final int? idCurso;
  const CursoEditarScreen({super.key, this.idCurso});

  @override
  State<CursoEditarScreen> createState() => _CursoEditarScreenState();
}

class _CursoEditarScreenState extends State<CursoEditarScreen>
    with TickerProviderStateMixin {
  // ── Estado ─────────────────────────────────────────────────────────────────
  int _selectedTab = 0; // 0: Lecciones, 1: Discusión
  final _tituloCtrl = TextEditingController(text: 'Ejemplo De Curso');
  final _scrollCtrl = ScrollController();
  final List<SeccionData> _secciones = [];

  // Animación de entrada del header
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFadeAnim;
  late Animation<Offset> _headerSlideAnim;

  // Animación del botón Guardar
  late AnimationController _guardarAnimCtrl;
  late Animation<double> _guardarScaleAnim;

  List<Map<String, int>> _leccionesCursosData = [];
  List<Leccion> _leccionesDelCurso = [];
  Curso? _cursoOriginal;

  @override
  void initState() {
    super.initState();

    if (widget.idCurso != null) {
      _cursoOriginal = BooklService().cursos.firstWhere(
        (c) => c.idCurso == widget.idCurso,
        orElse: () => Curso(
          idCurso: -1, 
          idUsuarioFk: AppSession().usuarioId ?? 1, 
          nombre: '', 
          estado: 'Borrador',
        ),
      );
      _tituloCtrl.text = _cursoOriginal!.nombre;
    }
    
    _refreshLeccionesLocales();

    // Header: fade + slide
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

    // Guardar: scale-in
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

    // Sección inicial por defecto
    _secciones.add(
      SeccionData(
        titulo: 'Introducción',
        cuerpo:
            'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean.',
      ),
    );
  }

  void _refreshLeccionesLocales() {
    if (widget.idCurso != null) {
      final idsLecciones = BooklService()
          .leccionesCursos
          .where((lc) => lc['id_curso'] == widget.idCurso)
          .map((lc) => lc['id_leccion'])
          .toList();

      _leccionesDelCurso = BooklService()
          .lecciones
          .where((l) => idsLecciones.contains(l.idLeccion))
          .toList();
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

  void _eliminarLeccion(Leccion leccion) {
    if (widget.idCurso == null) return;
    
    setState(() {
      BooklService().leccionesCursos.removeWhere((lc) => lc['id_curso'] == widget.idCurso && lc['id_leccion'] == leccion.idLeccion);
      _refreshLeccionesLocales();
    });
    // Notificamos para que la UI compartida o Home Screen recargue sus dependencias
    // En un escenario real esto consumiría la API y esperaría el refetch.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Lección eliminada',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC13030),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAssignLessonModal() {
    final myUserLessons = BooklService().lecciones.where((l) => l.idUsuarioFk == AppSession().usuarioId).toList();
    // Excluimos las que ya están en el curso
    final unassigned = myUserLessons.where((l) => !_leccionesDelCurso.any((c) => c.idLeccion == l.idLeccion)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFECEBEB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (unassigned.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No tienes lecciones disponibles para asignar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.black54),
            ),
          );
        }
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Selecciona una lección para asignar',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: unassigned.length,
                itemBuilder: (context, i) {
                  final l = unassigned[i];
                  return ListTile(
                    leading: const Icon(Icons.menu_book, color: Color(0xFF4DC130)),
                    title: Text(l.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(l.estado ?? '', style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      if (widget.idCurso != null) {
                        setState(() {
                          BooklService().leccionesCursos.add({
                            'id_leccion': l.idLeccion,
                            'id_curso': widget.idCurso!,
                          });
                          _refreshLeccionesLocales();
                        });
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // 1. Header
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _headerFadeAnim,
                  child: SlideTransition(
                    position: _headerSlideAnim,
                    child: _buildHeaderImage(context),
                  ),
                ),
              ),

              // 2. Cuerpo
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTituloEditable(),
                      const SizedBox(height: 20),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildTabs(),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _selectedTab == 0
                            ? Container(
                                key: const ValueKey(0),
                                child: _buildLeccionesEditor(),
                              )
                            : Container(
                                key: const ValueKey(1),
                                child: _buildDiscusionPlaceholder(),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Header (imagen roja = cursos)
  // ─────────────────────────────────────────────────────────────────────────
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
                  'assets/images/red_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFFFF606F)),
                ),
              ),
            ),
          ),

          // Overlay gradiente
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.93),
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
                    Icon(
                      Icons.edit_note_rounded,
                      size: 16,
                      color: Color(0xFFFF606F),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Modo Edición',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD63030),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Botones nav
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

  // ─────────────────────────────────────────────────────────────────────────
  // Título editable
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTituloEditable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    hintText: 'Título del curso...',
                  ),
                ),
              ),
              const Icon(Icons.edit, size: 16, color: Color(0xFFAAAAAA)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Metadata
        Row(
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
            const Text(
              'Ema Nuel',
              style: TextStyle(
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
              child: const Text(
                'Estudiante',
                style: TextStyle(
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
            const Text(
              '4.5',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats (igual a CursoDetailScreen)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            color: const Color(0xFFFF606F),
            icon: Icons.calendar_today_outlined,
            title: 'Creación',
            subtitle: '1 Marzo 2026',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            color: const Color(0xFFFEB95C),
            icon: Icons.star_border,
            title: 'Rate: 4.5',
            subtitle: '167 comentarios',
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tabs (Lecciones / Discusión)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        children: [
          _buildTabItem('Lecciones', 0),
          _buildTabItem('Discusión', 1),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Editor de Lecciones
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLeccionesEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Secciones de texto editables
        ...List.generate(_secciones.length, (i) {
          return SeccionEditorWidget(
            key: ValueKey(_secciones[i].hashCode),
            data: _secciones[i],
            index: i,
            onEliminar: () => _eliminarSeccion(i),
          );
        }),

        AgregarSeccionButton(onTap: _agregarSeccion),
        const SizedBox(height: 8),

        // Título sección Lecciones
        const Text(
          'Lecciones',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Lista de lecciones con controles de edición
        ...List.generate(_leccionesDelCurso.length, (i) {
          return _LeccionEditableCard(
            leccion: _leccionesDelCurso[i],
            onEditar: () => Navigator.push(
              context,
              _slideRoute(LeccionEditarScreen(idLeccion: _leccionesDelCurso[i].idLeccion)),
            ),
            onEliminar: () => _eliminarLeccion(_leccionesDelCurso[i]),
          );
        }),

        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
             onPressed: _showAssignLessonModal,
             icon: const Icon(Icons.add_link_rounded, color: Colors.white),
             label: const Text('Asignar lección existente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
             style: ElevatedButton.styleFrom(
               backgroundColor: const Color(0xFFFEB95C),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
             ),
          ),
        ),

        const SizedBox(height: 24),

        // Botón Guardar
        ScaleTransition(
          scale: _guardarScaleAnim,
          child: _GuardarButton(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Curso guardado exitosamente',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF4DC130),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscusionPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: const [
            Icon(Icons.forum_outlined, size: 54, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'La sección de Discusión se muestra\ndesde la vista del estudiante.',
              textAlign: TextAlign.center,
              style: TextStyle(
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

  /// Transición slide horizontal para el pusgh de LeccionEditarScreen
  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        return SlideTransition(position: slide, child: child);
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Tarjeta de lección con botones editar / eliminar (animados)
// ─────────────────────────────────────────────────────────────────────────────
class _LeccionEditableCard extends StatefulWidget {
  final Leccion leccion;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _LeccionEditableCard({
    required this.leccion,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  State<_LeccionEditableCard> createState() => _LeccionEditableCardState();
}

class _LeccionEditableCardState extends State<_LeccionEditableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.leccion;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Miniatura
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                   width: 74,
                   height: 74,
                   color: const Color(0xFF4DC130),
                   child: const Icon(Icons.menu_book, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categorías
                    Row(
                      children: [
                        _CategoryChip(
                          label: l.estado ?? 'Activa',
                          color: const Color(0xFF6BC654),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.nombre,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFF6B55C),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'N/A',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),

              // Controles: editar + eliminar + progreso
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón Editar (verde)
                  _ActionButton(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF4DC130),
                    onTap: widget.onEditar,
                    tooltip: 'Editar lección',
                  ),
                  const SizedBox(height: 6),
                  // Botón Eliminar (rojo)
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFC13030),
                    onTap: widget.onEliminar,
                    tooltip: 'Eliminar lección',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Micro-widgets reutilizables
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón de acción circular (editar / eliminar) con animación de press.
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Botón Guardar con gradiente + animación de press
// ─────────────────────────────────────────────────────────────────────────────
class _GuardarButton extends StatefulWidget {
  final VoidCallback onTap;
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
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
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
