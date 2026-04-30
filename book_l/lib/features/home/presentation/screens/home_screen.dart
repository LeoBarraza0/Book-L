import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../shared/widgets/content_cards.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../notificacion/presentation/widgets/notification_icon_button.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tenemos algunos materiales que podría ser de tu agrado:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Racha Buky
                      const RachaBukyWidget(),
                      const SizedBox(height: 24),

                      // Lecciones y Cursos desde el servicio JSON (Mixto)
                      ListenableBuilder(
                        listenable: BooklService(),
                        builder: (context, _) {
                          final lecciones = BooklService().lecciones
                              .where((l) => l.estado == 'activa')
                              .toList();
                          final cursos = BooklService().cursos
                              .where((c) => c.estado == 'Publicado')
                              .toList();
                              
                          if (lecciones.isEmpty && cursos.isEmpty) {
                            return const SizedBox();
                          }
                          
                          // Mezclamos en una sola lista (intercalados para FYP)
                          final mixedList = <Widget>[];
                          final maxLen = lecciones.length > cursos.length ? lecciones.length : cursos.length;
                          
                          for (int i = 0; i < maxLen; i++) {
                            if (i < cursos.length) {
                               mixedList.add(FypCursoCard(curso: cursos[i]));
                            }
                            if (i < lecciones.length) {
                               mixedList.add(FypLeccionCard(leccion: lecciones[i]));
                            }
                          }
                          
                          return Column(children: mixedList);
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
