import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../notificacion/presentation/screens/notificaciones_screen.dart';
import 'package:book_l/shared/widgets/create_menu_modal.dart' as lib_modal;
import 'editar_perfil.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../widgets/mis_contenidos_tab_widget.dart';
import '../widgets/mis_favoritos_tab_widget.dart';

import '../../../auth/domain/entities/usuario.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final session = AppSession();
    if (widget.idUsuario == null || widget.idUsuario == session.usuarioId) {
      _isOwnProfile = true;
      // Convert current session to a temporary Usuario object for UI consistency
      _user = Usuario(
        idUsuario: session.usuarioId ?? 0,
        nombreCompleto: session.nombreCompleto ?? 'Usuario',
        correo: '',
        rol: session.rol ?? 'Estudiante',
        programa: session.programa,
        activo: true,
      );
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
      backgroundColor: const Color(
        0xFFF4F7FB,
      ), 
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
                                      Navigator.pushReplacementNamed(context, '/home');
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
                                            builder: (context) => const NotificacionScreen(),
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
                                        color: const Color(0xFFFA8E9E), // Pink dot
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
                                      color: Color(0xFF4DC130), // Solid green border
                                      shape: BoxShape.circle,
                                    ),
                                    child: const CircleAvatar(
                                      radius: 45,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE8AB52), // Orange yellow badge
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 16),
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
                                      _user?.programa ?? _user?.rol ?? 'Estudiante',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isOwnProfile 
                                        ? '"Natty my love, Sharay my universe ✨ "\npsdt. Freddy mala paga'
                                        : 'Bienvenido a mi perfil académico en Book-L.',
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
                                final pubs = BooklService().cursos.where(
                                  (c) => c.idUsuarioFk == _user?.idUsuario
                                ).length;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildStatItem('Publicaciones', pubs.toString()),
                                    Container(width: 1, height: 35, color: Colors.black12),
                                    _buildStatItem('Seguidores', '77'),
                                    Container(width: 1, height: 35, color: Colors.black12),
                                    _buildStatItem('Seguidos', '777'),
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
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9BCE97), // Light green
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
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4DC130),
                              foregroundColor: Colors.white,
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
                              'Seguir',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                                margin: const EdgeInsets.only(top: 10, bottom: 6),
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
                              tabs: const [
                                Tab(icon: Icon(Icons.grid_on, size: 30)),
                                Tab(icon: Icon(Icons.favorite_border, size: 30)),
                              ],
                            ),
                            // Divider under tabs
                            const Divider(height: 1, color: Colors.black12, thickness: 1),
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
                  children: const [
                    // Grid Tab content
                    MisContenidosTabWidget(),
                    // Favorite Tab content
                    MisFavoritosTabWidget(),
                  ],
                ),
              ),
            ),
          ),

          // Floating Bottom Navigation Bar aligned as in design
          const Positioned(
            left: 20,
            right: 20,
            bottom: 30, // Elevated off bottom
            child: SharedBottomNavBar(
              selectedIndex: 2,
            ), // Index 2 is "Perfil" in the SharedBottomNavBar
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          // Using an icon to mimic the teacher graphic
          const Icon(
            Icons.co_present_outlined,
            size: 90,
            color: Colors.black38,
          ),
          const SizedBox(height: 24),

          const Text(
            'Comparte conocimiento',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Cuando compartes algún dato, aparecerán en tu perfil',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const lib_modal.CreateMenuModal();
                },
              );
            },
            child: const Text(
              'Sumate al desarrollo académico de la libre',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4DC130), // Main green
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4DC130),
              ),
            ),
          ),

          // Bottom padding to ensure the floating nav bar doesn't cover content
          const SizedBox(height: 120),
        ],
      ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

