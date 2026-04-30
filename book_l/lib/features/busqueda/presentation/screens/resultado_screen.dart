import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../controller/busqueda_controller.dart';
import '../../data/repositories/busqueda_repository.dart';
import '../../../notificacion/presentation/widgets/notification_icon_button.dart';

class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final BusquedaController _ctrl = BusquedaController();

  // ── Colores del Figma ─────────────────────────────────────────────────────
  static const _bgColor = Color(0xFFECEBEB);
  static const _headerGreen = Color(0xFF4DC130);
  static const _cardBg = Color(0xFFD9D9D9);

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
    _focusNode.dispose();
    super.dispose();
  }

  void _buscar(String query) {
    if (query.trim().isEmpty) return;
    _focusNode.unfocus();
    _ctrl.buscar(query);
  }

  void _navegarADetalle(ResultadoBusqueda item) {
    switch (item.tipo) {
      case 'Curso':
        Navigator.pushNamed(context, '/curso_detail', arguments: item.id);
      case 'Lección':
        Navigator.pushNamed(context, '/leccion_detail', arguments: item.id);
      default:
        // Autor → perfil de usuario
        Navigator.pushNamed(
          context,
          '/usuario_perfil',
          arguments: <String, String>{
            'name': item.titulo,
            'username': item.username ?? item.titulo,
            'imageUrl': item.avatarUrl ?? '',
          },
        );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              _buildFiltros(),
              Expanded(child: _buildCuerpo()),
            ],
          ),
          const Positioned(
            left: 11,
            right: 11,
            bottom: 20,
            child: SharedBottomNavBar(selectedIndex: 1),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(12, top + 12, 12, 16),
      decoration: const BoxDecoration(
        color: _headerGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila: atrás / notificaciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleBtn(
                icon: Icons.arrow_back,
                bg: const Color(0xFF3DA520),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    final role = BooklService().currentRole;
                    Navigator.pushReplacementNamed(
                        context, role == 'admin' ? '/admin_Home' : '/home');
                  }
                },
              ),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF3DA520),
                  shape: BoxShape.circle,
                ),
                child: const NotificationIconButton(
                  iconColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barra de búsqueda
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    cursorColor: _headerGreen,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Buscar cursos, lecciones...',
                      hintStyle: const TextStyle(
                          color: Color(0xFFAAAAAA), fontSize: 13),
                      contentPadding: const EdgeInsets.only(
                        left: 20,
                        top: 14,
                        bottom: 14,
                      ),
                      isDense: true,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _ctrl.buscar('');
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(Icons.close,
                                    size: 16, color: Color(0xFF666666)),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: _buscar,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _buscar(_searchController.text),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3DA520),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child:
                      const Icon(Icons.search, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  // ── Filtros pill ──────────────────────────────────────────────────────────
  Widget _buildFiltros() {
    return Container(
      color: _bgColor,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        itemCount: BusquedaController.filtros.length,
        itemBuilder: (context, index) {
          final filtro = BusquedaController.filtros[index];
          final isSelected = filtro == _ctrl.filtroActivo;
          return GestureDetector(
            onTap: () => _ctrl.cambiarFiltro(filtro),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? _headerGreen : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(50),
              ),
              alignment: Alignment.center,
              child: Text(
                filtro,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Cuerpo ────────────────────────────────────────────────────────────────
  Widget _buildCuerpo() {
    if (_ctrl.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _headerGreen, strokeWidth: 2),
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

  // ── Tarjeta fiel al Figma ─────────────────────────────────────────────────
  Widget _buildTarjeta(ResultadoBusqueda item) {
    return GestureDetector(
      onTap: () => _navegarADetalle(item),
      child: Container(
        height: 90,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Imagen izquierda ─────────────────────────────────────────
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 82,
                child: item.imagenUrl != null
                    ? Image.network(
                        item.imagenUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(item),
                      )
                    : _imgPlaceholder(item),
              ),
            ),

            // ── Contenido central ────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Badge de categoría (color oscuro, sin azul cielo)
                    _buildBadge(item),

                    // Título
                    Text(
                      item.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    // Subtítulo (autor / curso padre)
                    if (item.subtitulo != null)
                      Text(
                        item.subtitulo!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),

                    // Estrella + calificación
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF6B55C)),
                        const SizedBox(width: 3),
                        Text(
                          item.calificacion,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (item.inscripciones > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '| ${item.inscripciones} est.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Corazón + progreso ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Favorito con el mismo patrón del proyecto ─────────
                  _buildFavoriteButton(item),

                  // Progreso circular
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: item.progreso,
                          backgroundColor: const Color(0xFFCCCCCC),
                          color: _headerGreen,
                          strokeWidth: 3,
                        ),
                        Text(
                          '${(item.progreso * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Botón favorito — mismo patrón que content_cards.dart ────────────────
  Widget _buildFavoriteButton(ResultadoBusqueda item) {
    final isLeccion = item.tipo == 'Lección';
    final isCurso = item.tipo == 'Curso';

    if (!isLeccion && !isCurso) {
      // Para Autores: solo muestra el ícono sin toggle
      return const Icon(Icons.favorite_border_rounded,
          size: 20, color: Color(0xFFFF606F));
    }

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
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 20,
            color: const Color(0xFFFF606F),
          ),
        );
      },
    );
  }

  // ── Badge de tipo (sin azul cielo, todo oscuro/verde) ────────────────────
  Widget _buildBadge(ResultadoBusqueda item) {
    final (color, label) = switch (item.tipo) {
      'Lección' => (const Color(0xFF3DA520), 'Lección'),
      'Autor' => (const Color(0xFF5A5A8A), 'Autor'), // morado oscuro
      _ => (const Color(0xFF3DA520), 'Curso'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Placeholder de imagen ─────────────────────────────────────────────────
  Widget _imgPlaceholder(ResultadoBusqueda item) {
    return Container(
      color: item.colorTarjeta,
      child: Icon(
        item.tipo == 'Autor'
            ? Icons.person_rounded
            : item.tipo == 'Lección'
                ? Icons.menu_book_rounded
                : Icons.school_rounded,
        color: Colors.white.withOpacity(0.85),
        size: 32,
      ),
    );
  }
}
