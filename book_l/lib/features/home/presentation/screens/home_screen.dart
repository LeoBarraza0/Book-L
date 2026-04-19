import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../leccion/presentation/controller/leccion_controller.dart';
import '../../../leccion/domain/entities/leccion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _leccionCtrl = LeccionController();

  @override
  void initState() {
    super.initState();
    _leccionCtrl.cargarLecciones();
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
                      const Text(
                        '¡Bienvenido, Emanuel!',
                        style: TextStyle(
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
                      _buildRachaCard(),
                      const SizedBox(height: 24),

                      // Lecciones desde el servicio JSON
                      ListenableBuilder(
                        listenable: _leccionCtrl,
                        builder: (context, _) {
                          final state = _leccionCtrl.state;
                          if (state.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF4DC130)),
                            );
                          }
                          final lecciones = state.items
                              .where((l) => l.estado == 'activa')
                              .toList();
                          if (lecciones.isEmpty) {
                            return const SizedBox();
                          }
                          return Column(
                            children: lecciones
                                .map((l) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: _buildLeccionCard(
                                          context: context, leccion: l),
                                    ))
                                .toList(),
                          );
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
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notificaciones');
            },
            child: Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF96D786),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF949F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tarjeta de "Racha Buky"
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRachaCard() {
    final dias = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];
    // Marcamos los primeros 6 días como logrados (por ejemplo)
    final logrados = [true, true, true, true, true, true, false];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar Buky (Búho verde)
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF96D786),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/racha.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.pets, color: Colors.green, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Textos y Racha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Saluda a tu Racha Buky!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '¡Completa una lección cada día para que tu racha crezca como tu conocimiento!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 12),
                // Círculos de días
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    return Column(
                      children: [
                        Text(
                          dias[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A5757),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: logrados[index]
                                ? const Color(0xFF96D786)
                                : const Color(0xFFB0B0B0),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tarjeta de Lección (datos reales del servicio)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLeccionCard({
    required BuildContext context,
    required Leccion leccion,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/leccion_detail',
        arguments: leccion.idLeccion,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFFD9D9D9),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4DC130), Color(0xFF3AAA26)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.menu_book_rounded,
                        color: Colors.white.withOpacity(0.25), size: 80),
                  ),
                ),
                // Estado badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DC130),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      leccion.estado ?? 'Lección',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 12,
                  right: 12,
                  child: Icon(Icons.favorite_border,
                      color: Color(0xFFFF606F), size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  leccion.nombre,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Row(children: [
                Icon(Icons.star, color: Color(0xFFF6B55C), size: 18),
                SizedBox(width: 4),
                Text('4.9',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
