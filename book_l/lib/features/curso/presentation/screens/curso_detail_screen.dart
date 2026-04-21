import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../discusion/presentation/screens/discusion_screen.dart';
import '../../../discusion/presentation/widgets/comentario_input.dart';
import '../../../discusion/presentation/controller/discusion_controller.dart';
import '../../../leccion/presentation/screens/leccion_detail_screen.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';
import '../controller/curso_controller.dart';
import 'curso_editar_screen.dart';
import '../../../leccion/presentation/controller/leccion_controller.dart';
import '../../../../shared/widgets/quill_read_only_view.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/services/bookl_service.dart';

class CursoDetailScreen extends StatefulWidget {
  final int? idCurso;
  const CursoDetailScreen({super.key, this.idCurso});

  @override
  State<CursoDetailScreen> createState() => _CursoDetailScreenState();
}

class _CursoDetailScreenState extends State<CursoDetailScreen> {
  int _selectedTab = 0;
  final CursoController _ctrl = CursoController();
  final DiscusionController _discCtrl = DiscusionController();

  @override
  void initState() {
    super.initState();
    if (widget.idCurso != null) {
      _ctrl.seleccionarCurso(widget.idCurso!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeaderImage(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndProgress(),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 80.0, // 42 tab height + 24 bottom padding + SafeArea/top padding
                  maxHeight: 80.0,
                  child: Container(
                    color: const Color(0xFFECEBEB),
                    padding: const EdgeInsets.only(top: 14.0, bottom: 24.0, left: 20, right: 20),
                    child: _buildTabs(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Render Dinámico según la Pestaña
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _selectedTab == 0
                            ? Container(
                                key: const ValueKey(0),
                                child: _buildLeccionesContent(),
                              )
                            : Container(
                                key: const ValueKey(1),
                                child: _buildDiscusionContent(),
                              ),
                      ),
                      const SizedBox(height: 100), // Espacio para NavBar
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Input de Comentarios Flotante (Solo en pestaña Discusión) ──
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            bottom: _selectedTab == 1 ? 110 : -60,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _selectedTab == 1 ? 1.0 : 0.0,
              child: ComentarioInput(ctrl: _discCtrl),
            ),
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
                      Container(color: Colors.grey[400]),
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
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      ListenableBuilder(
                        listenable: _ctrl,
                        builder: (context, _) {
                          final isOwner = _ctrl.state.selected?.idUsuarioFk == AppSession().usuarioId;
                          if (isOwner) {
                            return Row(
                              children: [
                                _buildCircularIconButton(
                                  Icons.edit,
                                  () => Navigator.push(context, _slideRoute(CursoEditarScreen(
                                    idCurso: widget.idCurso,
                                  ))),
                                  color: const Color(0xFFFEB95C),
                                ),
                                const SizedBox(width: 10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      ListenableBuilder(
                        listenable: AppSession().savedCursos,
                        builder: (context, _) {
                          final isSaved = widget.idCurso != null && AppSession().savedCursos.value.contains(widget.idCurso!);
                          return _buildCircularIconButton(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            () {
                              if (widget.idCurso != null) {
                                AppSession().toggleSavedCurso(widget.idCurso!);
                              }
                            },
                            color: isSaved ? Colors.redAccent : const Color(0xFF6BCA54),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildCircularIconButton(Icons.share, () {}),
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
      {Color color = const Color(0xFF6BCA54)}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
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

  /// Transición slide horizontal para navegaciones
  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }

  Widget _buildTitleAndProgress() {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final curso = _ctrl.state.selected;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso?.nombre ?? 'Cargando...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: BooklService(),
                    builder: (context, _) {
                      final creator = BooklService().usuarios.cast<dynamic>().firstWhere(
                        (u) => (u as dynamic).idUsuario == curso?.idUsuarioFk,
                        orElse: () => null,
                      );
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(PerfilScreen(idUsuario: creator?.idUsuario)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF6BCA54),
                              child: Icon(Icons.person, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              creator?.nombreCompleto ?? 'Cargando...',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF6BCA54),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF79AC63),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                creator?.rol ?? 'Estudiante',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '|  4.5',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: AppSession().completedCapitulos,
              builder: (context, _) {
                final progress = curso != null 
                    ? _ctrl.calcularProgresoCurso(curso.idCurso) 
                    : 0.0;
                final percent = (progress * 100).toInt();

                return SizedBox(
                  width: 65,
                  height: 65,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 65,
                        height: 65,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFFD9D9D9),
                          color: const Color(0xFF4DC130),
                          strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF606F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.black87,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Creación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ListenableBuilder(
                      listenable: _ctrl,
                      builder: (context, _) {
                        final date = _ctrl.state.selected?.createdAt;
                        return Text(
                          _formatDate(date),
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEB95C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_border, color: Colors.black87, size: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate: 4.5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ListenableBuilder(
                      listenable: BooklService(), // Listener dummy or actual comments controller if it existed
                      builder: (context, _) => const Text(
                        '0 comentarios',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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
          duration: const Duration(milliseconds: 200),
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
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscusionContent() {
    return Column(
      children: [
        const SizedBox(height: 10),
        DiscusionScreen(
          showRating: true,
          idCurso: widget.idCurso,
          controller: _discCtrl,
        )
      ],
    );
  }

  Widget _buildLeccionesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            final contenido = _ctrl.state.selected?.contenido;
            if (contenido == null || contenido.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  'Aún no hay introducción disponible para este curso.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF787878),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contenido.map((s) {
                final titulo = s['titulo'] as String? ?? '';
                final deltaData = s['cuerpo_delta'] as List<dynamic>?;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titulo.isNotEmpty) ...[
                        Text(
                          titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                      ],
                      QuillReadOnlyView(
                        delta: deltaData,
                        fontSize: 16,
                        color: const Color(0xFF787878),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 32),
        const Text(
          'Lecciones',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            final lecciones = _ctrl.leccionesDeCurso;
            if (lecciones.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Aún no hay lecciones en este curso.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF787878),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final l in lecciones) ...[
                  _buildLeccionCard(
                    category: 'Lección',
                    title: l.nombre,
                    duration: '--',
                    rating: l.rating > 0 ? l.rating.toStringAsFixed(1) : '--',
                    students: l.estudiantes > 0 ? '${l.estudiantes} est.' : '--',
                    progress: l.progreso,
                    imageUrl: l.imagenUrl ?? '',
                    idLeccion: l.idLeccion,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeccionCard({
    required String category,
    Color categoryColor = const Color(0xFF6BC654),
    String? category2,
    Color? categoryColor2,
    required String title,
    required String duration,
    required String rating,
    required String students,
    required double progress,
    required String imageUrl,
    int? idLeccion,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        _slideRoute(LeccionDetailScreen(idLeccion: idLeccion)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ), // Padding dinámico y natural
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Imagen de portada con fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 74,
                        height: 74,
                        color: const Color(0xFF4DC130).withOpacity(0.3),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Color(0xFF4DC130), size: 32),
                      ),
                    )
                  : Container(
                      width: 74,
                      height: 74,
                      color: const Color(0xFF4DC130).withOpacity(0.25),
                      child: const Icon(Icons.menu_book_rounded,
                          color: Color(0xFF4DC130), size: 32),
                    ),
            ),
            const SizedBox(width: 14),
            // Contenido en texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Categorías superpuestas
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (category2 != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor2,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            category2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Rating y número de estudiantes
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF6B55C),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 10, color: Colors.black26),
                      const SizedBox(width: 8),
                      Text(
                        students,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Columna derecha: Corazón de favoritos y Progreso circular
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (idLeccion != null)
                  ListenableBuilder(
                    listenable: AppSession().savedLecciones,
                    builder: (context, _) {
                      final isSaved = AppSession().savedLecciones.value.contains(idLeccion);
                      return GestureDetector(
                        onTap: () {
                          AppSession().toggleSavedLeccion(idLeccion);
                        },
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: AppSession().completedCapitulos,
                  builder: (context, _) {
                    final dynProgress = idLeccion != null 
                        ? LeccionController().calcularProgresoLeccion(idLeccion)
                        : 0.0;
                    
                    return SizedBox(
                      width: 32,
                      height: 32,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: dynProgress,
                            backgroundColor: Colors.transparent,
                            color: const Color(0xFF4DC130),
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${(dynProgress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

