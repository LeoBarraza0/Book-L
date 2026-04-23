import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../../../../core/services/bookl_service.dart';
import '../controller/busqueda_controller.dart';

class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BusquedaController _ctrl = BusquedaController();

  final List<String> _filtros = ['Todas', 'Recientes', 'Calificación', '...'];
  int _filtroSeleccionado = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = _ctrl.currentQuery;
    _ctrl.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChange);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3), // Un gris super claro de fondo
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Cabecera Verde
              _buildHeader(context),

              // 2. Chips de filtro
              _buildFiltros(),

              // 3. Resultados
              Expanded(
                child: _ctrl.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF4DC130)),
                      )
                    : _ctrl.resultados.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron resultados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 5,
                              bottom: 100, // Espacio para el Bottom Navigation Bar
                            ),
                            itemCount: _ctrl.resultados.length,
                            itemBuilder: (context, index) {
                              return _buildResultCard(_ctrl.resultados[index]);
                            },
                          ),
              ),
            ],
          ),

          // Barra de Navegación Compartida
          const Positioned(
            left: 20,
            right: 20,
            bottom: 30, // Elevated off bottom
            child: SharedBottomNavBar(selectedIndex: 1), // Index 1 is Buscar
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 10,
        right: 15,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF4DC130), // Verde sólido del figma
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Fila Superior (Atrás y Notificaciones)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                        final role = BooklService().currentRole;
                        Navigator.pushReplacementNamed(
                          context,
                          role == 'admin' ? '/admin_Home' : '/home',
                        );
                      }
                    },
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
                          Navigator.pushReplacementNamed(
                            context,
                            '/notificaciones',
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
          const SizedBox(height: 14),

          // Fila del Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Barra de Búsqueda Blanca (Píldora)
                Expanded(
                  child: Container(
                    height: 44, // Más compacta
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _searchController,
                      cursorColor: const Color(0xFF5AB639),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (val) {
                        _ctrl.buscar(val);
                      },
                      style: const TextStyle(
                        color: Color(0xFF444444), // Texto gris oscuro
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(
                          left: 16,
                          top: 13,
                          bottom: 13,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF666666),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _ctrl.buscar('');
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Botón Lupa (SIN fondo circular, puro ícono blanco como en Figma)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white, size: 32),
                  onPressed: () {
                    _ctrl.buscar(_searchController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _filtros.length,
        itemBuilder: (context, index) {
          final isSelected = index == _filtroSeleccionado;
          return GestureDetector(
            onTap: () {
              setState(() {
                _filtroSeleccionado = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF54B435)
                    : const Color(0xFFE2E2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _filtros[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> item) {
    // Renderear múltiples tabs
    List<Map<String, dynamic>> tags = item['tags'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5), // Tarjeta gris ligeramente oscura
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Imagen (Cuadrado con bordes redondeados y un color/placeholder de fondo)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: item['imageColor'], // Color simulando la imagen
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: Colors.white54,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),

          // Información Central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Categoría Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tag['color'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag['text'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tag['textColor'],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),

                // Título
                Text(
                  item['titulo'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Estadísticas
                Row(
                  children: [
                    Text(
                      item['duracion'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF6B55C)),
                    const SizedBox(width: 4),
                    Text(
                      item['calificacion'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '| ${item['estudiantes']} estudiantes',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Columna de Acciones y Progreso
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                item['favorito']
                    ? Icons.favorite_border
                    : Icons
                          .favorite_border, // En tu Figma, la mayoría son bordes rojos
                color: item['favorito']
                    ? const Color(0xFFFF4040)
                    : const Color(0xFFFF4040),
                size: 24,
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      value: item['progreso'],
                      backgroundColor: const Color(0xFFD4D4D4),
                      color: const Color(0xFF5AB639),
                      strokeWidth: 3.5,
                    ),
                  ),
                  Text(
                    '${(item['progreso'] * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
