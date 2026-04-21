import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filters_widget.dart';
import '../../domain/entities/usuarios.dart';
import '../../domain/repositories/usuarios_repository.dart';
import '../../domain/usecases/get_usuarios_usecase.dart';
import '../../data/repositories/usuarios_repository_impl.dart';
import '../controller/usuarios_controller.dart';
import '../controller/usuarios_state.dart';
import 'edit_usuario_screen.dart';
import 'add_usuario_screen.dart';

/// Crea y provee el [UsuariosController] con todas sus dependencias.
///
/// Este "mini-injector" manual es suficiente para la fase JSON local.
/// Cuando se integre un DI real (get_it, riverpod, etc.) se elimina
/// este factory y el controller se inyecta desde fuera.
UsuariosController _buildController() {
  final UsuariosRepository repo = UsuariosRepositoryImpl();
  return UsuariosController(
    getUsuarios: GetUsuariosUseCase(repo),
    addUsuario: AddUsuarioUseCase(repo),
    updateUsuario: UpdateUsuarioUseCase(repo),
    deleteUsuario: DeleteUsuarioUseCase(repo),
  );
}

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  late final UsuariosController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _filtros = ['Todos', 'Recientes', 'Activos', 'Inactivos'];
  int _filtroSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _controller.cargarUsuarios();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  List<Usuario> _applyFilters(List<Usuario> todos) {
    var result = todos;
    if (_filtroSeleccionado == 2) {
      result = result.where((u) => u.activo).toList();
    } else if (_filtroSeleccionado == 3) {
      result = result.where((u) => !u.activo).toList();
    }

    if (_query.isNotEmpty) {
      result = result
          .where((u) =>
              u.nombreCompleto.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    return result;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E1), // Crema claro
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          return Stack(
            children: [
              // ── COLUMNA PRINCIPAL ──────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── HEADER: Imagen PNG de fondo con overlay de contenido ──
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          // Fondo PNG
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/yellow_bg.png',
                              fit: BoxFit.cover,
                            ),
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
                          // Icono campana (esquina superior derecha)
                          Positioned(
                            top: topPadding + 8,
                            right: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          // Título "Usuarios"
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 80,
                            child: Center(
                              child: Text(
                                'Usuarios',
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
                  ),

                  // ── ZONA GRIS con búsqueda, filtros y listado ──────────────
                  Expanded(
                    child: Column(
                      children: [
                        CustomSearchBar(
                          controller: _searchController,
                          onSearch: () {
                            setState(() => _query = _searchController.text);
                          },
                          onClear: () {
                            setState(() => _query = '');
                          },
                        ),
                        FilterChipsRow(
                          filters: _filtros,
                          selectedIndex: _filtroSeleccionado,
                          onFilterSelected: (index) {
                            setState(() => _filtroSeleccionado = index);
                          },
                        ),
                        Expanded(child: _buildBody(state)),
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
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () async {
            final newUser = await Navigator.push<Usuario>(
              context,
              MaterialPageRoute(
                builder: (context) => const AddUsuarioScreen(),
              ),
            );
            if (newUser != null) {
              await _controller.agregarUsuario(newUser);
            }
          },
          backgroundColor: const Color(0xFF44BD32),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Construye el cuerpo según el estado actual del controller.
  Widget _buildBody(UsuariosState state) {
    if (state is UsuariosLoading || state is UsuariosInitial) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF175e7a)),
      );
    }

    if (state is UsuariosError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFEA5455), fontSize: 14),
          ),
        ),
      );
    }

    if (state is UsuariosLoaded) {
      final filtrados = _applyFilters(state.usuarios);
      if (filtrados.isEmpty) {
        return const Center(
          child: Text(
            'No hay usuarios disponibles',
            style: TextStyle(color: Color(0xFF888888)),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 100,
        ),
        itemCount: filtrados.length,
        itemBuilder: (context, index) => _buildUsuarioCard(filtrados[index]),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildUsuarioCard(Usuario user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Fondo suave para el avatar
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              image: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Center(
                    child: Text(
                      _getInitials(user.nombreCompleto),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44BD32),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Info central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                Text(
                  user.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Correo
                Text(
                  user.correo,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E90FF),
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Teléfono
                Text(
                  user.celular?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                // Rol & Estado
                Row(
                  children: [
                    if (user.rol != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: user.rol == 'Admin'
                              ? const Color(0xFFF19066)
                              : user.rol == 'Profesor'
                                  ? const Color(0xFF175e7a)
                                  : const Color(0xFF44BD32),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.rol!,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.activo
                            ? const Color(0xFF44BD32)
                            : const Color(0xFFEA5455),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.activo ? 'Activo' : 'Inactivo',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
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
                color: const Color(0xFFF6B55C),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () async {
                    final updatedUser = await Navigator.push<Usuario>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUsuarioScreen(usuario: user),
                      ),
                    );
                    if (updatedUser != null) {
                      await _controller.editarUsuario(updatedUser);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: const Color(0xFFEA5455),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _mostrarModalEliminar(user),
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 32,
                    width: 32,
                    alignment: Alignment.center,
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarModalEliminar(Usuario user) {
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    '¿Eliminar Usuario?',
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
                  'Tenga en cuenta que esta acción no se podrá \nrevertir',
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
                        await _controller.eliminarUsuario(user.idUsuario);
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
