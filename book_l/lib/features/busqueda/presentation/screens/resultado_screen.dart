import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../controller/busqueda_controller.dart';
import '../../data/repositories/busqueda_repository.dart';
import '../../../perfil/presentation/screens/perfil_screen.dart';
import '../../../leccion/presentation/controller/leccion_controller.dart';
import '../../../curso/presentation/controller/curso_controller.dart';

class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BusquedaController _ctrl = BusquedaController();

  static const _bgColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _searchController.text = _ctrl.currentQuery;
    _ctrl.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_rebuild);
    _searchController.dispose();
    super.dispose();
  }

  void _navegarADetalle(ResultadoBusqueda item) {
    switch (item.tipo) {
      case 'Curso':
        Navigator.pushNamed(context, '/curso_detail', arguments: item.id);
        break;
      case 'Lección':
        Navigator.pushNamed(context, '/leccion_detail', arguments: item.id);
        break;
      default:
        // PerfilScreen con idUsuario
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PerfilScreen(idUsuario: item.id),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final slide = Tween<Offset>(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(position: slide, child: child);
            },
            transitionDuration: const Duration(milliseconds: 380),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildFiltros(),
                const SizedBox(height: 8),
                Expanded(child: _buildCuerpo()),
              ],
            ),
            const Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: SharedBottomNavBar(selectedIndex: 1),
            ),
          ],
        ),
      ),
    );
  }

  // Header similar a busqueda_screen.dart pero con onTap a pop
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF5AB639),
              size: 28,
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                final role = BooklService().currentRole.toLowerCase();
                if (role == 'administrador' || role == 'admin') {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/admin_Home', (route) => false);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                }
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/busqueda');
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  enabled:
                      false, // Read only, tap is handled by GestureDetector
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Buscar cursos, lecciones, autores...',
                    hintStyle: TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5AB639), Color(0xFF4DC130)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  // Filtros pill
  Widget _buildFiltros() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: BusquedaController.filtros.length,
        itemBuilder: (context, index) {
          final filtro = BusquedaController.filtros[index];
          final isSelected = filtro == _ctrl.filtroActivo;
          return GestureDetector(
            onTap: () => _ctrl.cambiarFiltro(filtro),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5AB639) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5AB639)
                      : const Color(0xFFE0E0E0),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                filtro,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Cuerpo
  Widget _buildCuerpo() {
    if (_ctrl.isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(color: Color(0xFF5AB639), strokeWidth: 2),
      );
    }
    if (_ctrl.currentQuery.isEmpty) {
      return _emptyState(Icons.search, 'Escribe algo para buscar');
    }
    if (_ctrl.resultados.isEmpty) {
      return _emptyState(
          Icons.search_off, 'Sin resultados para "${_ctrl.currentQuery}"');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
      itemCount: _ctrl.resultados.length,
      itemBuilder: (_, i) => _buildTarjeta(_ctrl.resultados[i]),
    );
  }

  Widget _emptyState(IconData icon, String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 50, color: const Color(0xFFCCCCCC)),
          const SizedBox(height: 10),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888))),
        ],
      ),
    );
  }

  // ── Tarjeta unificada con badge de tipo + autor ──────────────────────────
  Widget _buildTarjeta(ResultadoBusqueda item) {
    // Determinar badge color y label
    final (
      Color badgeColor,
      String badgeLabel,
      Color iconBoxColor,
      Color iconColor,
      IconData iconData
    ) = switch (item.tipo) {
      'Curso' => (
          const Color(0xFFFF606F),
          'Curso',
          const Color(0xFFFF606F).withValues(alpha: 0.2),
          const Color(0xFFFF606F),
          Icons.school_rounded
        ),
      'Lección' => (
          const Color(0xFF4DC130),
          'Lección',
          const Color(0xFF4DC130),
          Colors.white,
          Icons.menu_book_rounded
        ),
      _ => (
          const Color(0xFF5A5A8A),
          'Autor',
          const Color(0xFF5A5A8A).withValues(alpha: 0.2),
          const Color(0xFF5A5A8A),
          Icons.person_rounded
        ),
    };

    // Obtener imagen
    String? imageUrl;
    if (item.tipo == 'Curso') {
      final curso =
          BooklService().cursos.where((c) => c.idCurso == item.id).firstOrNull;
      imageUrl = _extractImageUrl(curso?.contenido);
    } else if (item.tipo == 'Lección') {
      final leccion = BooklService()
          .lecciones
          .where((l) => l.idLeccion == item.id)
          .firstOrNull;
      imageUrl = _extractImageUrl(leccion?.contenido);
    } else {
      imageUrl = item.avatarUrl;
    }

    // Obtener nombre del autor
    final autorNombre = _getAutorNombre(item);

    return GestureDetector(
      onTap: () => _navegarADetalle(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Imagen
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: iconBoxColor,
                      borderRadius: BorderRadius.circular(16),
                      image: imageUrl != null && imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: imageUrl == null || imageUrl.isEmpty
                        ? Icon(iconData, color: iconColor, size: 40)
                        : const SizedBox(),
                  ),
                ),
                const SizedBox(width: 14),
                // Contenido
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 50, top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Badge de tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Título
                        Text(
                          item.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Autor o subtitulo
                        if (autorNombre != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                item.tipo == 'Autor'
                                    ? Icons.badge_outlined
                                    : Icons.person_outline_rounded,
                                size: 13,
                                color: const Color(0xFF888888),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  autorNombre,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF888888),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Rating (solo para Curso/Lección)
                        if (item.tipo != 'Autor') ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFB800), size: 14),
                              const SizedBox(width: 3),
                              Text(
                                item.calificacion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Favorito (arriba derecha)
            if (item.tipo == 'Curso' || item.tipo == 'Lección')
              Positioned(
                top: 12,
                right: 16,
                child: _buildFavoriteButton(item),
              ),
            // Progreso (abajo derecha)
            if (item.tipo == 'Curso' || item.tipo == 'Lección')
              Positioned(
                bottom: 12,
                right: 16,
                child: _buildProgressCircle(item),
              ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String? _getAutorNombre(ResultadoBusqueda item) {
    if (item.tipo == 'Curso') {
      // subtitulo ya tiene el autor del curso (de _autorDeCurso en el repo)
      return item.subtitulo;
    } else if (item.tipo == 'Lección') {
      // Buscar el autor de la lección por idUsuarioFk
      final leccion = BooklService()
          .lecciones
          .where((l) => l.idLeccion == item.id)
          .firstOrNull;
      if (leccion != null) {
        final autor = BooklService()
            .usuarios
            .where((u) => u.idUsuario == leccion.idUsuarioFk)
            .firstOrNull;
        if (autor != null) return autor.nombreCompleto;
      }
      // Fallback al subtitulo (nombre del curso padre)
      return item.subtitulo;
    } else {
      // Autor: mostrar programa
      return item.subtitulo;
    }
  }

  Widget _buildFavoriteButton(ResultadoBusqueda item) {
    final isLeccion = item.tipo == 'Lección';
    final listenable =
        isLeccion ? AppSession().savedLecciones : AppSession().savedCursos;

    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final isSaved = isLeccion
            ? AppSession().savedLecciones.value.contains(item.id)
            : AppSession().savedCursos.value.contains(item.id);

        return GestureDetector(
          onTap: () {
            if (isLeccion) {
              AppSession().toggleSavedLeccion(item.id);
            } else {
              AppSession().toggleSavedCurso(item.id);
            }
          },
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            color: Colors.redAccent,
            size: 24,
          ),
        );
      },
    );
  }

  Widget _buildProgressCircle(ResultadoBusqueda item) {
    return ListenableBuilder(
      listenable: AppSession().completedCapitulos,
      builder: (context, _) {
        final double progress;
        final Color progressColor;

        if (item.tipo == 'Lección') {
          progress = LeccionController().calcularProgresoLeccion(item.id);
          progressColor = const Color(0xFF4DC130);
        } else {
          progress = CursoController().calcularProgresoCurso(item.id);
          progressColor = const Color(0xFFFF606F);
        }

        final percent = (progress * 100).toInt();
        return SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.2),
                color: progressColor,
                strokeWidth: 4,
              ),
              Center(
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _extractImageUrl(List<dynamic>? contenido) {
    if (contenido == null || contenido.isEmpty) return null;
    final first = contenido.first;
    if (first is Map && first['tiene_imagen'] == true) {
      return first['imagen_url']?.toString();
    }
    return null;
  }
}
