import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import '../controller/busqueda_controller.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late BusquedaController _ctrl;

  @override
  void initState() {
    super.initState();
    context.read<BusquedaController>().recargarHistorial();
    // Escribir resto del initState si es necesario...
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────
  void _onTextChanged(String text) {
    _ctrl.actualizarSugerencias(text);
  }

  void _onSubmitted(String text) {
    _ejecutarBusqueda(text);
  }

  void _ejecutarBusqueda(String query) {
    if (query.trim().isEmpty) return;
    _searchController.text = query;
    _focusNode.unfocus();
    _ctrl.buscar(query);
    Navigator.pushNamed(context, '/resultado');
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _ctrl = context.watch<BusquedaController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitulo(),
                const SizedBox(height: 16),
                _buildBarraBusqueda(),
                const SizedBox(height: 24),
                // Sugerencias o historial
                if (_ctrl.mostrandoSugerencias && _ctrl.sugerencias.isNotEmpty)
                  _buildSugerencias()
                else
                  _buildHistorial(),
              ],
            ),

            // Bottom Navigation Bar flotante
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

  // ── Widgets ───────────────────────────────────────────────────────────────
  Widget _buildTitulo() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Text(
        'Búsqueda',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildBarraBusqueda() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Botón atrás
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

          // Campo de búsqueda
          Expanded(
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
                focusNode: _focusNode,
                cursorColor: const Color(0xFF5AB639),
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar cursos, lecciones, autores...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                    left: 20,
                    top: 14,
                    bottom: 14,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Color(0xFF888888), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _ctrl.ocultarSugerencias();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: _onTextChanged,
                onSubmitted: _onSubmitted,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botón buscar
          GestureDetector(
            onTap: () => _ejecutarBusqueda(_searchController.text),
            child: Container(
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
          ),
        ],
      ),
    );
  }

  // ── Sugerencias en tiempo real (estilo YouTube) ───────────────────────────
  Widget _buildSugerencias() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ctrl.sugerencias.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
          itemBuilder: (context, index) {
            final sugerencia = _ctrl.sugerencias[index];
            return ListTile(
              leading: const Icon(
                Icons.search,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
              title: _buildSugerenciaTexto(sugerencia),
              trailing: IconButton(
                icon: const Icon(Icons.north_west,
                    size: 16, color: Color(0xFFCCCCCC)),
                tooltip: 'Completar búsqueda',
                onPressed: () {
                  _searchController.text = sugerencia;
                  _ctrl.actualizarSugerencias(sugerencia);
                  setState(() {});
                },
              ),
              onTap: () => _ejecutarBusqueda(sugerencia),
            );
          },
        ),
      ),
    );
  }

  // Resalta en verde la parte del texto que coincide con la query
  Widget _buildSugerenciaTexto(String sugerencia) {
    final query = _searchController.text;
    final lowerS = sugerencia.toLowerCase();
    final lowerQ = query.toLowerCase();
    final idx = lowerS.indexOf(lowerQ);

    if (idx < 0 || query.isEmpty) {
      return Text(sugerencia,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        children: [
          if (idx > 0) TextSpan(text: sugerencia.substring(0, idx)),
          TextSpan(
            text: sugerencia.substring(idx, idx + query.length),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4DC130),
            ),
          ),
          TextSpan(text: sugerencia.substring(idx + query.length)),
        ],
      ),
    );
  }

  // ── Historial de búsquedas ────────────────────────────────────────────────
  Widget _buildHistorial() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado historial
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Búsquedas recientes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
                if (_ctrl.historial.isNotEmpty)
                  GestureDetector(
                    onTap: _ctrl.limpiarHistorial,
                    child: const Text(
                      'Limpiar todo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5AB639),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista de historial
          Expanded(
            child: _ctrl.historial.isEmpty
                ? _buildHistorialVacio()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 110),
                    itemCount: _ctrl.historial.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.history,
                            color: Color(0xFFCCCCCC), size: 22),
                        title: Text(
                          _ctrl.historial[index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _searchController.text = _ctrl.historial[index];
                          _ejecutarBusqueda(_ctrl.historial[index]);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.close,
                              color: Color(0xFFCCCCCC), size: 18),
                          onPressed: () => _ctrl.eliminarDelHistorial(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialVacio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Color(0xFFDDDDDD)),
          SizedBox(height: 12),
          Text(
            'No tienes búsquedas recientes',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFFBBBBBB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
