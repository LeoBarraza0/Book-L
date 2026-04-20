import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filters_widget.dart';
import '../../domain/entities/usuarios.dart';
import 'edit_usuario_screen.dart';
import 'add_usuario_screen.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _filtros = ['Todos', 'Recientes', 'Activos', '...'];
  int _filtroSeleccionado = 0;

  final List<Usuario> _usuarios = [
    Usuario(
      idUsuario: 1,
      nombreCompleto: 'Arthur Barraza',
      correo: 'arthurbr@gmail.com',
      password: '...',
      username: 'arthurbr',
      celular: 3001234567,
      semestre: 8,
      nacimiento: DateTime(1998, 5, 15),
      programa: 'Ingenieria de Sistemas',
      preferencias: 'IA y móviles.',
      activo: true,
      rol: 'Admin',
    ),
    Usuario(
      idUsuario: 2,
      nombreCompleto: 'Maria Lopez',
      correo: 'marialopez@gmail.com',
      password: '...',
      username: 'mlopez',
      celular: 3109876543,
      semestre: 4,
      nacimiento: DateTime(2002, 11, 20),
      programa: 'Psicologia',
      preferencias: 'Psicología clínica.',
      activo: true,
      rol: 'User',
    ),
    Usuario(
      idUsuario: 3,
      nombreCompleto: 'Juan Perez',
      correo: 'juanperez@gmail.com',
      password: '...',
      username: 'jperez',
      celular: 3201112233,
      semestre: 10,
      nacimiento: DateTime(1997, 1, 5),
      programa: 'Derecho',
      preferencias: 'Derecho penal.',
      activo: false,
      rol: 'User',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Logic for filtering by query and filter state
    var filteredUsuarios = _usuarios;
    if (_filtroSeleccionado == 2) {
      filteredUsuarios = _usuarios.where((u) => u.activo).toList();
    }
    if (_query.isNotEmpty) {
      filteredUsuarios = filteredUsuarios
          .where((u) => u.nombreCompleto.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          // ── COLUMNA PRINCIPAL ──────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER: Imagen PNG de fondo con overlay de contenido
              SizedBox(
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

              // ── ZONA GRIS con búsqueda, filtros y listado ──────────────
              Expanded(
                child: Column(
                  children: [
                    CustomSearchBar(
                      controller: _searchController,
                      onSearch: () {
                        setState(() {
                          _query = _searchController.text;
                        });
                      },
                      onClear: () {
                        setState(() {
                          _query = '';
                        });
                      },
                    ),
                    FilterChipsRow(
                      filters: _filtros,
                      selectedIndex: _filtroSeleccionado,
                      onFilterSelected: (index) {
                        setState(() {
                          _filtroSeleccionado = index;
                        });
                      },
                    ),
                    Expanded(
                      child: filteredUsuarios.isEmpty
                          ? const Center(
                              child: Text('No hay usuarios disponibles',
                                  style: TextStyle(color: Color(0xFF888888))))
                          : ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                                bottom: 100,
                              ),
                              itemCount: filteredUsuarios.length,
                              itemBuilder: (context, index) {
                                return _buildUsuarioCard(
                                    filteredUsuarios[index]);
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 80.0), // Padding to avoid covering the nav bar
        child: FloatingActionButton(
          onPressed: () async {
            final newUser = await Navigator.push<Usuario>(
              context,
              MaterialPageRoute(
                builder: (context) => const AddUsuarioScreen(),
              ),
            );
            if (newUser != null) {
              setState(() {
                _usuarios.add(newUser);
              });
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

  Widget _buildUsuarioCard(Usuario user) {
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
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.person, color: Color(0xFF888888), size: 40),
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
                // Telefono
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
                color:
                    const Color(0xFFF6B55C), // Naranja para editar en usuarios
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
                      setState(() {
                        final index = _usuarios.indexWhere((u) => u.idUsuario == user.idUsuario);
                        if (index != -1) {
                          _usuarios[index] = updatedUser;
                        }
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                color: const Color(0xFFEA5455), // Rojo para eliminar
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _mostrarModalEliminar(user),
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      onPressed: () {
                        setState(() {
                          _usuarios.removeWhere((u) => u.idUsuario == user.idUsuario);
                        });
                        Navigator.pop(ctx);
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

