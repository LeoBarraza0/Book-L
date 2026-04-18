import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../controller/leccion_controller.dart';
import '../../domain/entities/leccion.dart';

class AdminLeccionScreen extends StatefulWidget {
  const AdminLeccionScreen({super.key});

  @override
  State<AdminLeccionScreen> createState() => _AdminLeccionScreenState();
}

class _AdminLeccionScreenState extends State<AdminLeccionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _leccionCtrl = LeccionController();
  String _query = '';

  final List<String> _filtros = ['Todas', 'Recientes', 'Calificación', '...'];
  int _filtroSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _leccionCtrl.cargarLecciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _leccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          // ── COLUMNA PRINCIPAL ──────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER: SVG completo como fondo con overlay de contenido
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Fondo SVG
                    SvgPicture.asset(
                      'assets/images/green_bg.svg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Botón atrás (esquina superior izquierda)
                    Positioned(
                      top: topPadding + 8,
                      left: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/admin_Home',
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    // Título "Lecciones" (centrado horizontalmente y con ajuste vertical)
                    Positioned(
                      left: 0,
                      right: 0,
                      top:
                          80, // Se cambia este valor para subir o bajar el título
                      child: const Center(
                        child: Text(
                          'Lecciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontFamily: 'Baloo',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── ZONA GRIS con búsqueda, filtros y listado ──────────────
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildFiltros(),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: _leccionCtrl,
                        builder: (context, _) {
                          final state = _leccionCtrl.state;
                          if (state.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4DC130)),
                            );
                          }
                          var lecciones = state.items.toList();
                          if (_query.isNotEmpty) {
                            lecciones = lecciones
                                .where((l) => l.nombre
                                    .toLowerCase()
                                    .contains(_query.toLowerCase()))
                                .toList();
                          }
                          if (lecciones.isEmpty) {
                            return const Center(
                                child: Text('No hay lecciones disponibles',
                                    style: TextStyle(
                                        color: Color(0xFF888888))));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 100,
                            ),
                            itemCount: lecciones.length,
                            itemBuilder: (context, index) {
                              return _buildLeccionCard(lecciones[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── BOTTOM NAV BAR ─────────────────────────────────────────────
          const Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xFF5AB639),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'Buscar lección...',
                  hintStyle: const TextStyle(color: Color(0xFF888888)),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _query = '';
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF888888),
                      size: 18,
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF5AB639),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5AB639), width: 2),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: _filtros.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == _filtroSeleccionado;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filtroSeleccionado = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5AB639)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeccionCard(Leccion item) {
    final nCapitulos = _leccionCtrl.capitulosDe(item.idLeccion).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF7BC85A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 12),

          // Info central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.estado == 'activa'
                        ? const Color(0xFF67C947)
                        : const Color(0xFF888888),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.estado ?? 'lección',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),

                // Título
                Text(
                  item.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  nCapitulos == 1
                      ? '1 Capítulo'
                      : '$nCapitulos Capítulos',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(Icons.star, size: 13, color: Color(0xFFF6B55C)),
                    SizedBox(width: 3),
                    Text('4.9',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Botones Editar / Eliminar
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: const Color(0xFF5AB639),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/editar_leccion',
                    arguments: item.idLeccion,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 28,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text('Editar',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _mostrarModalEliminar(item),
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 28,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text('Eliminar',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarModalEliminar(Leccion item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '¿Eliminar Lección?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tenga en cuenta que esta acción no se podrá revertir',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF49454F),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar',
                          style: TextStyle(
                              color: Color(0xFFFF5252),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _leccionCtrl
                            .eliminarLeccion(item.idLeccion);
                      },
                      child: const Text('Aceptar',
                          style: TextStyle(
                              color: Color(0xFF4DC130),
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
