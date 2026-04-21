import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart' as bookl;
import '../controller/reporte_detail_controller.dart';
import '../../domain/usecases/get_reportes_por_entidad_usecase.dart';
import '../../data/repositories/reportes_repository_impl.dart';

ReporteDetailController _buildDetailController() {
  final repo = ReportesRepositoryImpl();
  return ReporteDetailController(
    getReportesPorEntidadUseCase: GetReportesPorEntidadUseCase(repo),
  );
}

class ReporteDetailScreen extends StatefulWidget {
  final int idLeccion;
  final String leccionNombre;
  final String tipo;

  const ReporteDetailScreen({
    super.key,
    required this.idLeccion,
    required this.leccionNombre,
    required this.tipo,
  });

  @override
  State<ReporteDetailScreen> createState() => _ReporteDetailScreenState();
}

class _ReporteDetailScreenState extends State<ReporteDetailScreen> {
  late final ReporteDetailController _controller;
  final List<String> _filters = ['Más Recientes', 'Más Antiguos'];

  @override
  void initState() {
    super.initState();
    _controller = _buildDetailController();
    _controller.loadDetalles(widget.tipo, widget.idLeccion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFECEBEB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildCourseInfo(),
                const SizedBox(height: 20),
                _buildStatsCards(),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 24),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => _buildCommentsList(),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: SharedBottomNavBar(selectedIndex: 3),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Para asegurar que cubra todo, usamos un Transform.scale ligero o simplemente width infinito
    return Transform.scale(
      scaleX: 1.02, // Evita lineas blancas laterales
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/red_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.tipo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NOTE: Se mantiene aquí por ser dependiente del mock DB, sin embargo
  // arquitecturalmente debería cruzar desde el Home u obtenerse en el Backend.
  // BooklService() es nuestro DB transitorio.
  Widget _buildCourseInfo() {
    final service = bookl.BooklService();
    String authorName = 'Desconocido';
    String authorRole = 'N/A';

    if (widget.tipo == 'Curso') {
      final curso = service.cursos.where((c) => c.idCurso == widget.idLeccion).firstOrNull;
      if (curso != null) {
        final author = service.usuarios.where((u) => u.idUsuario == curso.idUsuarioFk).firstOrNull;
        if (author != null) {
          authorName = author.nombreCompleto;
          authorRole = author.rol;
        }
      }
    } else if (widget.tipo == 'Lección') {
      final leccion = service.lecciones.where((l) => l.idLeccion == widget.idLeccion).firstOrNull;
      if (leccion != null) {
        final author = service.usuarios.where((u) => u.idUsuario == leccion.idUsuarioFk).firstOrNull;
        if (author != null) {
          authorName = author.nombreCompleto;
          authorRole = author.rol;
        }
      }
    } else if (widget.tipo == 'Capítulo') {
      final capitulo = service.capitulos.where((c) => c.idCapitulo == widget.idLeccion).firstOrNull;
      if (capitulo != null) {
        final leccion = service.lecciones.where((l) => l.idLeccion == capitulo.idLeccion).firstOrNull;
        if (leccion != null) {
          final author = service.usuarios.where((u) => u.idUsuario == leccion.idUsuarioFk).firstOrNull;
          if (author != null) {
            authorName = author.nombreCompleto;
            authorRole = author.rol;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.leccionNombre,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF5AB639),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  authorName.isNotEmpty ? authorName[0] : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              authorName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 10),
            const Text('|', style: TextStyle(color: Colors.black54)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7CB342),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                authorRole,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final service = bookl.BooklService();
    final reports = service.reportes.where((r) => 
      r['entidad_tipo']?.toString().toLowerCase() == widget.tipo.toLowerCase() && r['entidad_id'] == widget.idLeccion).toList();
    
    String fechaCreacion = 'N/A';
    if (widget.tipo == 'Curso') {
      final curso = service.cursos.where((c) => c.idCurso == widget.idLeccion).firstOrNull;
      if (curso != null && curso.createdAt != null) {
        fechaCreacion = curso.createdAt!.toString().split(' ')[0];
      }
    } else if (widget.tipo == 'Lección') {
      final leccion = service.lecciones.where((l) => l.idLeccion == widget.idLeccion).firstOrNull;
      if (leccion != null && leccion.createdAt != null) {
        fechaCreacion = leccion.createdAt!.toString().split(' ')[0];
      }
    } else if (widget.tipo == 'Capítulo') {
      final capitulo = service.capitulos.where((c) => c.idCapitulo == widget.idLeccion).firstOrNull;
      if (capitulo != null && capitulo.createdAt != null) {
        fechaCreacion = capitulo.createdAt!.toString().split(' ')[0];
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF606F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.black87, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Creación',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        fechaCreacion,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.black87, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Reportes:',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      Text(
                        '${reports.length} Pendientes',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _controller.selectedSort == filter;
              return GestureDetector(
                onTap: () => _controller.onChangeSort(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5AB639)
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildCommentsList() {
    if (_controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF5AB639))),
      );
    }
    
    if (_controller.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${_controller.errorMessage}', style: const TextStyle(color: Colors.red)));
    }

    final comentarios = _controller.comentarios;

    if (comentarios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Extrañamente no se encontraron motivos para este reporte.', style: TextStyle(color: Colors.black54)),
      );
    }

    return Column(
      children: comentarios.map((item) {
        final date = item.reporte.createdAt.toString().split(' ')[0];
        return _buildCommentItem(
          item.nombreUsuario, 
          item.reporte.motivo, 
          date,
          item.avatarUrl
        );
      }).toList(),
    );
  }

  Widget _buildCommentItem(String name, String message, String date, String? avatarUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF5AB639),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null 
                        ? const Icon(Icons.person, size: 20, color: Colors.white)
                        : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Responder',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
