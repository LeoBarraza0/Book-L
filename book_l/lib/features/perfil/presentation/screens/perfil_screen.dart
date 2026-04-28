import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../notificacion/presentation/screens/notificaciones_screen.dart';
import 'package:book_l/shared/widgets/create_menu_modal.dart' as lib_modal;
import 'editar_perfil.dart';
import 'seguidores_screen.dart';
import '../widgets/mis_cursos_section.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../widgets/mis_contenidos_tab_widget.dart';
import '../widgets/mis_favoritos_tab_widget.dart';

import '../../../auth/domain/entities/usuario.dart';
import '../../../../shared/widgets/custom_avatar.dart';

class PerfilScreen extends StatefulWidget {
  final int? idUsuario;
  const PerfilScreen({super.key, this.idUsuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Usuario? _user;
  bool _isOwnProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: _isOwnProfile ? 2 : 1, vsync: this);
  }

  void _loadUserData() {
    final session = AppSession();
    if (widget.idUsuario == null || widget.idUsuario == session.usuarioId) {
      _isOwnProfile = true;
      try {
        _user = BooklService().usuarios.firstWhere(
              (u) => u.idUsuario == session.usuarioId,
            );
      } catch (e) {
        // Convert current session to a temporary Usuario object for UI consistency
        _user = Usuario(
          idUsuario: session.usuarioId ?? 0,
          nombreCompleto: session.nombreCompleto ?? 'Usuario',
          correo: '',
          rol: session.rol ?? 'Estudiante',
          programa: session.programa,
          activo: true,
        );
      }
    } else {
      _isOwnProfile = false;
      try {
        _user = BooklService().usuarios.firstWhere(
              (u) => u.idUsuario == widget.idUsuario,
            );
      } catch (e) {
        _user = null;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Stack(
        children: [
          // Background Gradient (Optional slight top blue blur as in Figma)
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3EFFC),
                  Color(0x00F4F7FB), // transparent to match base
                ],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Custom App Bar / Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF88D288),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      final role = BooklService().currentRole;
                                      Navigator.pushReplacementNamed(
                                          context,
                                          role == 'admin'
                                              ? '/admin_Home'
                                              : '/home');
                                    }
                                  },
                                ),
                              ),
                              Text(
                                '@${(_user?.nombreCompleto ?? 'usuario').replaceAll(" ", "").toLowerCase()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              // Notification bell with badge
                              Stack(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF88D288),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificacionScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFFA8E9E), // Pink dot
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF4F7FB),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Profile Information (Photo + Text)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(
                                          0xFF4DC130), // Solid green border
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomAvatar(
                                      radius: 45,
                                      url: _user?.avatarUrl,
                                      nombre: _user?.nombreCompleto ?? 'Usuario',
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(
                                            0xFFE8AB52), // Orange yellow badge
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              // Name and details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _user?.nombreCompleto ?? 'Usuario',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      _user?.programa ??
                                          _user?.rol ??
                                          'Estudiante',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _user?.descripcion?.isNotEmpty == true
                                          ? _user!.descripcion!
                                          : 'Aún no hay una descripción añadida.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Stats Box
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9CD19A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListenableBuilder(
                              listenable: BooklService(),
                              builder: (context, _) {
                                final pubs = BooklService()
                                    .cursos
                                    .where((c) =>
                                        c.idUsuarioFk == _user?.idUsuario)
                                    .length;
                                final followersCount = BooklService()
                                    .getFollowersCount(_user?.idUsuario ?? 0);
                                final followingCount = BooklService()
                                    .getFollowingCount(_user?.idUsuario ?? 0);
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildStatItem(
                                        'Publicaciones', pubs.toString()),
                                    Container(
                                        width: 1,
                                        height: 35,
                                        color: Colors.black12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SeguidoresScreen(
                                              idUsuarioFocus:
                                                  _user?.idUsuario ?? 0,
                                              isSeguidores: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildStatItem('Seguidores',
                                          followersCount.toString()),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 35,
                                        color: Colors.black12),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SeguidoresScreen(
                                              idUsuarioFocus:
                                                  _user?.idUsuario ?? 0,
                                              isSeguidores: false,
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildStatItem('Seguidos',
                                          followingCount.toString()),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Editar perfil button
                        if (_isOwnProfile)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditarPerfil(),
                                ),
                              ).then((_) {
                                setState(() {
                                  _loadUserData();
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF9BCE97), // Light green
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Editar perfil',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          )
                        else
                          ListenableBuilder(
                              listenable: BooklService(),
                              builder: (context, _) {
                                final isFollowing = BooklService().isFollowing(
                                    AppSession().usuarioId ?? 0,
                                    _user?.idUsuario ?? 0);
                                return ElevatedButton(
                                  onPressed: () {
                                    if (AppSession().usuarioId != null &&
                                        _user?.idUsuario != null) {
                                      BooklService().toggleSeguir(
                                          AppSession().usuarioId!,
                                          _user!.idUsuario);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFollowing
                                        ? Colors.grey[300]
                                        : const Color(0xFF4DC130),
                                    foregroundColor: isFollowing
                                        ? Colors.black87
                                        : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    isFollowing ? 'Siguiendo' : 'Seguir',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                );
                              }),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      minHeight: 75.0,
                      maxHeight: 75.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FB),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Pestañita para arrastrar
                            Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.only(top: 10, bottom: 6),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Tab Bar
                            TabBar(
                              controller: _tabController,
                              indicatorColor: const Color(0xFF4DC130),
                              indicatorWeight: 4,
                              labelColor: const Color(0xFF4DC130),
                              unselectedLabelColor: Colors.grey,
                              tabs: [
                                const Tab(icon: Icon(Icons.grid_on, size: 30)),
                                if (_isOwnProfile)
                                  const Tab(
                                      icon: Icon(Icons.favorite_border,
                                          size: 30)),
                              ],
                            ),
                            // Divider under tabs
                            const Divider(
                                height: 1, color: Colors.black12, thickness: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                color: const Color(0xFFF4F7FB),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Grid Tab content
                    MisContenidosTabWidget(
                        idUsuario:
                            widget.idUsuario ?? AppSession().usuarioId ?? 0),
                    // Favorite Tab content (solo si es el propio perfil)
                    if (_isOwnProfile) const MisFavoritosTabWidget(),
                  ],
                ),
              ),
            ),
          ),

          // Floating Bottom Navigation Bar aligned as in design
          Positioned(
            left: 20,
            right: 20,
            bottom: 30, // Elevated off bottom
            child: SharedBottomNavBar(
              selectedIndex: _isOwnProfile ? 2 : -1,
            ), // Index 2 is "Perfil" in the SharedBottomNavBar
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesAccess() {
    return MisCursosSection(
      onMisCursosTap: () {
        Navigator.pushNamed(context, '/publicar_curso');
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  _SliverAppBarDelegate({
    required this.child,
    required this.maxHeight,
    required this.minHeight,
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
