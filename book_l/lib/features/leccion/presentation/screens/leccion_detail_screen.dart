import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../discusion/presentation/screens/discusion_screen.dart';
import '../../../discusion/presentation/widgets/comentario_input.dart';
import '../../../ejercicio/presentation/screens/ejercicios_screen.dart';
import '../controller/leccion_controller.dart';
import '../../domain/entities/capitulo.dart';
import '../../../../core/storage/local_storage.dart';

enum CapituloStatus { completed, inProgress, locked }

class LeccionDetailScreen extends StatefulWidget {
  /// ID de la lección a mostrar. Si es null muestra datos placeholder.
  final int? idLeccion;

  const LeccionDetailScreen({super.key, this.idLeccion});

  @override
  State<LeccionDetailScreen> createState() => _LeccionDetailScreenState();
}

class _LeccionDetailScreenState extends State<LeccionDetailScreen> {
  int _selectedTab = 0; // 0: Contenido, 1: Ejercicios, 2: Discusión
  final LeccionController _ctrl = LeccionController();

  @override
  void initState() {
    super.initState();
    if (widget.idLeccion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.seleccionarLeccion(widget.idLeccion!);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB), // Color de fondo del layout
      body: Stack(
        children: [
          // ── Contenido Principal (Scroll) ─────────────────────────────
          CustomScrollView(
            slivers: [
              // 1. Imagen Superior (Header) 
              SliverToBoxAdapter(child: _buildHeaderImage(context)),

              // 2. Cuerpo del detalle
              // 2. Cuerpo del detalle superior a los tabs
              SliverToBoxAdapter(
                child: ListenableBuilder(
                    listenable: _ctrl,
                    builder: (context, _) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleAndProgress(),
                            const SizedBox(height: 24),
                            _buildCursosAsociados(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      );
                    }),
              ),
              // 3. Tabs (Persistent Header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 80.0, // 42 (tab height) + 24 (bottom padding) + top padding
                  maxHeight: 80.0,
                  child: Container(
                    color: const Color(0xFFECEBEB),
                    padding: const EdgeInsets.only(top: 14.0, bottom: 24.0, left: 20, right: 20),
                    child: _buildTabs(),
                  ),
                ),
              ),
              // 4. Cuerpo dinámico debajo de los tabs
              SliverToBoxAdapter(
                child: ListenableBuilder(
                    listenable: _ctrl,
                    builder: (context, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // Render Dinámico según la Pestaña animado
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: _selectedTab == 0
                                  ? Container(key: const ValueKey(0), child: _buildContenido())
                                  : _selectedTab == 1
                                      ? const EjerciciosScreen(key: ValueKey(1))
                                      : Container(
                                          key: const ValueKey(2),
                                          child: const DiscusionScreen(showRating: true),
                                        ),
                            ),
                            const SizedBox(
                              height: 100,
                            ), // Espacio extra para el NavBar Flotante
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),

          // ── Input de Comentarios Flotante (Solo en pestaña Discusión) ──
          ListenableBuilder(
            listenable: _ctrl,
            builder: (context, _) => AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              bottom: _selectedTab == 2 ? 110 : -60,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _selectedTab == 2 ? 1.0 : 0.0,
                child: const ComentarioInput(),
              ),
            ),
          ),

          // ── Bottom Navigation Bar flotante ───────────────────────────
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
  // Componentes Privados
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeaderImage(BuildContext context) {
    return SizedBox(
      height: 300, // Altura ajustada similar al diseño de Figma (298px)
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Transform.scale(
                scale: 1.15, // Ajusta el zoom para ignorar bordes transparentes integrados del PNG original
                child: Image.asset(
                  'assets/images/green_bg.png', // image 36 de Figma (local version)
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[400]),
                ),
              ),
            ),
          ),
          // Botones Top (Nav)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircularIconButton(
                      Icons.arrow_back, () => Navigator.pop(context)),
                  Row(
                    children: [
                      ListenableBuilder(
                        listenable: _ctrl,
                        builder: (context, _) {
                          final leccion = _ctrl.state.selected;
                          if (leccion != null && leccion.idUsuarioFk == AppSession().usuarioId) {
                            return Row(
                              children: [
                                _buildCircularIconButton(
                                  Icons.edit_rounded,
                                  () {
                                    Navigator.pushNamed(context, '/editar_leccion', arguments: leccion.idLeccion);
                                  },
                                ),
                                const SizedBox(width: 10),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      ListenableBuilder(
                        listenable: AppSession().savedLecciones,
                        builder: (context, _) {
                          final isSaved = widget.idLeccion != null && AppSession().savedLecciones.value.contains(widget.idLeccion!);
                          return _buildCircularIconButton(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            () {
                              if (widget.idLeccion != null) {
                                AppSession().toggleSavedLeccion(widget.idLeccion!);
                              }
                            },
                            color: isSaved ? Colors.redAccent.withOpacity(0.9) : const Color(0xFF6BCA54).withOpacity(0.9),
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

  Widget _buildCircularIconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFF6BCA54).withOpacity(0.9), // Más visible sobre imagen
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

  Widget _buildTitleAndProgress() {
    final leccion = _ctrl.state.selected;
    final titulo = leccion?.nombre ?? 'Cargando...';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título + Info del Autor
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFF6BCA54),
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('Autor_id', // TODO: Cargar autor real
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: const Color(0xFF79AC63),
                        borderRadius: BorderRadius.circular(4)),
                    child: const Text('Comunidad',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  const Text('|  4.5',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                ],
              ),
            ],
          ),
        ),

        // Círculo de Progreso
        const SizedBox(
          width: 65,
          height: 65,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 65,
                child: CircularProgressIndicator(
                  value: 0.2, // 20%
                  strokeWidth: 6,
                  backgroundColor: Color(0xFFD9D9D9),
                  color: Color(0xFF4DC130),
                  strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                ),
              ),
              Text(
                '20%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCursosAsociados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cursos asociados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCursoAsociadoItem(context, width: 110),
              const SizedBox(width: 12),
              _buildCursoAsociadoItem(context, width: 110),
              const SizedBox(width: 12),
              _buildCursoAsociadoItem(context, width: 110),
              const SizedBox(width: 12),
              _buildCursoAsociadoItem(context, width: 110),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCursoAsociadoItem(BuildContext context, {required double width}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/curso_detail');
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF81CF6E),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
                        offset: Offset(0, 2))
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

  Widget _buildContenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Introducción ──
        const Text('Introducción',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text(
          'Lorem ipsum dolor sit amet consectetur adipiscing elit quisque faucibus ex sapien vitae pellentesque sem placerat in id cursus mi pretium tellus duis convallis tempus leo eu aenean sed diam urna tempor pulvinar vivamus fringilla lacus nec metus bibendum egestas iaculis massa nisl malesuada lacinia integer nunc posuere ut hendrerit.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF787878),
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),

        // ── Capítulos ──
        const Text('Capítulos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) {
            final caps = _ctrl.capitulosDeLeccion;
            if (caps.isEmpty) {
              // Placeholder visual mientras no hay lección seleccionada
              return _buildCapitulosPlaceholder();
            }
            return Column(
              children: [
                for (int i = 0; i < caps.length; i++) ...[
                  _buildCapituloItem(
                    status: i == 0
                        ? CapituloStatus.completed
                        : i == 1
                            ? CapituloStatus.inProgress
                            : CapituloStatus.locked,
                    title: caps[i].nombre,
                    duration: _formatDuracion(caps[i].tiempoTotal),
                    number: i + 1,
                    capitulo: caps[i],
                  ),
                  if (i < caps.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 32),

        // ── Material Relacionado ──
        const Text('Material Relacionado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _buildMaterialItem(
            icon: Icons.insert_drive_file,
            title: 'Limites y continuidad',
            duration: '15 minutos'),
        const SizedBox(height: 12),
        _buildMaterialItem(
            icon: Icons.play_arrow,
            title: 'Limites y continuidad',
            duration: '15 minutos',
            iconColor: const Color(0xFFFF606F)),
        const SizedBox(height: 32),

        // ── Autor ──
        const Text('Autor',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _buildAutorCard(),
      ],
    );
  }

  // Convierte segundos a texto legible (ej: 900 → "15 min")
  String _formatDuracion(int segundos) {
    if (segundos < 60) return '$segundos seg';
    final mins = segundos ~/ 60;
    if (mins < 60) return '$mins min';
    final horas = mins ~/ 60;
    final resto = mins % 60;
    return resto == 0 ? '${horas}h' : '${horas}h ${resto}min';
  }

  // Placeholder cuando la lección aún no se ha cargado
  Widget _buildCapitulosPlaceholder() {
    return Column(
      children: List.generate(3, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )),
    );
  }

  Widget _buildCapituloItem({
    required CapituloStatus status,
    required String title,
    required String duration,
    int? number,
    Capitulo? capitulo,
  }) {
    bool isLocked = status == CapituloStatus.locked;
    bool isInProgress = status == CapituloStatus.inProgress;
    bool isCompleted = status == CapituloStatus.completed;

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Navigator.pushNamed(context, '/capitulo_detail');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
          border: isInProgress
              ? Border.all(color: const Color(0xFF4DC130), width: 2)
              : null,
        ),
        child: Row(
          children: [
          // Icono Redondo o Número
          if (isCompleted)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: Color(0xFF4DC130), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked
                    ? const Color(0xFFAFAFAF)
                    : const Color(0xFFBDBDBD),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                number?.toString() ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 16),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(duration,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF676767),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          // Etiqueta "En curso" si aplica
          if (isInProgress)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFF4DC130).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('En curso',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    ),
  );
  }

  Widget _buildMaterialItem({
    required IconData icon,
    required String title,
    required String duration,
    Color iconColor = const Color(0xFF4DC130),
  }) {
    return Container(
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
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(duration,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF676767),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_outlined,
              size: 20, color: Color(0xFF787878)),
        ],
      ),
    );
  }

  Widget _buildAutorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://picsum.photos/100/100?random=1', // Placeholder temporal
              width: 75,
              height: 75,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(width: 75, height: 75, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Emanuel Barranco',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 6),
                const Text('Estudiante de Ingeniería de Sistemas',
                    style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
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
