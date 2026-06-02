import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:book_l/shared/widgets/nav_bar.dart';
import 'package:book_l/shared/widgets/content_cards.dart';
import '../controller/home_controller.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/notificacion/infrastructure/adapters/in/presentation/widgets/notification_icon_button.dart';
import 'widgets/racha_buky_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeController = context.watch<HomeController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Contenido Principal (Scroll) ─────────────────────────────
          CustomScrollView(
            slivers: [
              // Header blanco superior
              SliverToBoxAdapter(child: _buildTopHeader(context)),

              // Sección de Bienvenida
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido, ${AppSession().nombreCompleto?.split(' ').first ?? 'Usuario'}!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tenemos algunos materiales que podría ser de tu agrado:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Racha Buky
                      const RachaBukyWidget(),
                      const SizedBox(height: 24),

                      // Lecciones y Cursos desde el servicio JSON (Mixto)
                      Builder(
                        builder: (context) {
                          final mixedList = homeController.getForYouPageItems();

                          if (mixedList.isEmpty) {
                            return const SizedBox();
                          }

                          final widgets = mixedList.map<Widget>((item) {
                            if (item.runtimeType.toString() == 'Curso') {
                              return FypCursoCard(curso: item);
                            } else {
                              return FypLeccionCard(leccion: item);
                            }
                          }).toList();

                          return Column(children: widgets);
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom Navigation Bar flotante ───────────────────────────
          const Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SharedBottomNavBar(selectedIndex: -1),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header superior blanco
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        50,
        20,
        20,
      ), // Padding para el SafeArea
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Ajustes
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/configuracion');
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF96D786),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings, color: Colors.white),
            ),
          ),

          // Logo Central
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 60,
            fit: BoxFit.contain,
          ),

          // Botón Notificaciones
          const NotificationIconButton(isGreenCircle: true),
        ],
      ),
    );
  }
}
