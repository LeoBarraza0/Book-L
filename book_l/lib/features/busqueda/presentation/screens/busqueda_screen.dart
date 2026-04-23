import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../controller/busqueda_controller.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BusquedaController _ctrl = BusquedaController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _eliminarBusqueda(int index) {
    _ctrl.eliminarDelHistorial(index);
  }

  void _ejecutarBusqueda(String query) {
    if (query.trim().isNotEmpty) {
      _ctrl.buscar(query);
      Navigator.pushNamed(context, '/resultado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título superior
                const Padding(
                  padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Text(
                    'Busqueda',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Fila del buscador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // Botón atrás sin fondo
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(), // Minimiza el padding extra
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF5AB639), // Verde más fuerte similar a Figma
                          size: 32, // Un poco más grande como en la imagen
                        ),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(width: 12),

                      // Campo de búsqueda ampliado
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCDCDC), // Gris parecido al de Figma
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _searchController,
                            cursorColor: const Color(0xFF5AB639),
                            textInputAction: TextInputAction.search,
                            onSubmitted: _ejecutarBusqueda,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                left: 20,
                                top: 14,
                                bottom: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.close, // El ícono de la X dentro del input
                                  color: Color(0xFF555555),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                  });
                                },
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botón buscar separado
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF67BC44), // Verde fuerte
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () {
                            _ejecutarBusqueda(_searchController.text);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 35),

                // Título de sección historial
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Búsquedas previas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Lista de Historial
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _ctrl.historialBusquedas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(
                          Icons.history,
                          color: Color(0xFFBDBDBD),
                        ),
                        title: Text(
                          _ctrl.historialBusquedas[index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          _searchController.text = _ctrl.historialBusquedas[index];
                          _ejecutarBusqueda(_ctrl.historialBusquedas[index]);
                        },
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFFBDBDBD),
                            size: 20,
                          ),
                          onPressed: () => _eliminarBusqueda(index),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 100), // Reserve space for bottom nav
              ],
            ),

            // Floating Bottom Navigation Bar
            const Positioned(
              left: 20,
              right: 20,
              bottom: 30, // Elevated off bottom
              child: SharedBottomNavBar(selectedIndex: 1), // Index 1 is Buscar
            ),
          ],
        ),
      ),
    );
  }
}
