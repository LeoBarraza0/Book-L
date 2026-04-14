import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart'; // Import from shared widgets
import '../../../notificacion/presentation/screens/notificaciones_screen.dart';
import 'package:book_l/shared/widgets/create_menu_modal.dart' as lib_modal;
import 'editar_perfil.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Custom App Bar / Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(
                            0xFF88D288,
                          ), // Lighter green for header buttons
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

                      const Text(
                        '@Manu7u7',
                        style: TextStyle(
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
                                ), // Matching background border
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
                      // Profile image with green border and + badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              5,
                            ), // Border thickness
                            decoration: const BoxDecoration(
                              color: Color(0xFF4DC130), // Solid green border
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=11',
                              ), // Placeholder photo
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
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
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
                            const Text(
                              'Emanuel Barranco',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              'Ing. Sistemas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"Natty my love, Sharay my universe ✨ "\npsdt. Freddy mala paga',
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
                      color: const Color(
                        0xFF9CD19A,
                      ), // Muted green matching the stats background
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildStatItem('Publicaciones', '0'),
                        Container(width: 1, height: 35, color: Colors.black12),
                        _buildStatItem('Seguidores', '77'),
                        Container(width: 1, height: 35, color: Colors.black12),
                        _buildStatItem('Seguidos', '777'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Editar perfil button
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
                ),

                const SizedBox(height: 25),

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
                const Divider(height: 1, color: Colors.black12),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Grid Tab content (Empty state)
                      _buildEmptyState(),
                      // Favorite Tab
                      const Center(
                        child: Text(
                          'Favoritos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
