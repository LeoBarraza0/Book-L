import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';

class AdminLeccionScreen extends StatefulWidget {
  const AdminLeccionScreen({super.key});

  @override
  State<AdminLeccionScreen> createState() => _AdminLeccionScreenState();
}

class _AdminLeccionScreenState extends State<AdminLeccionScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filtros = ['Todas', 'Recientes', 'Calificación', '...'];
  int _filtroSeleccionado = 0;

  final List<Map<String, dynamic>> _lecciones = [
    {
      'tags': [
        {
          'text': 'POO',
          'color': const Color(0xFF67C947),
          'textColor': Colors.white,
        },
      ],
      'titulo': 'Ejemplo de lección 1',
      'capitulos': '3 Capítulos',
      'calificacion': '4.9',
      'estudiantes': '1.200',
      'imageColor': const Color(0xFF7BC85A),
    },
    {
      'tags': [
        {
          'text': 'IEEE',
          'color': const Color(0xFFFA8E9E),
          'textColor': Colors.white,
        },
      ],
      'titulo': 'Ejemplo de lección 2',
      'capitulos': '10 capítulos',
      'calificacion': '4.9',
      'estudiantes': '1.200',
      'imageColor': const Color(0xFFFF6B8B),
    },
    {
      'tags': [
        {
          'text': 'POO',
          'color': const Color(0xFF67C947),
          'textColor': Colors.white,
        },
        {
          'text': 'IA',
          'color': const Color(0xFFF6B55C),
          'textColor': Colors.white,
        },
      ],
      'titulo': 'Ejemplo de lección 3',
      'capitulos': '7 Capítulos',
      'calificacion': '4.9',
      'estudiantes': '1.200',
      'imageColor': const Color(0xFFFFB347),
    },
    {
      'tags': [
        {
          'text': 'POO',
          'color': const Color(0xFF67C947),
          'textColor': Colors.white,
        },
      ],
      'titulo': 'Ejemplo de lección 4',
      'capitulos': '8 Capítulos',
      'calificacion': '4.9',
      'estudiantes': '1.200',
      'imageColor': const Color(0xFFFFB347),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFECEBEB),
      body: Stack(
        children: [
          // ── COLUMNA PRINCIPAL ──────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER: SVG completo como fondo con overlay de contenido
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Fondo SVG
                    SvgPicture.asset(
                      'assets/images/green_bg.svg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
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
                    // Título "Lecciones" (centrado horizontalmente y con ajuste vertical)
                    Positioned(
                      left: 0,
                      right: 0,
                      top:
                          80, // Se cambia este valor para subir o bajar el título
                      child: const Center(
                        child: Text(
                          'Lecciones',
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
                    _buildSearchBar(),
                    _buildFiltros(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 100,
                        ),
                        itemCount: _lecciones.length,
                        itemBuilder: (context, index) {
                          return _buildLeccionCard(_lecciones[index]);
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
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Campo de búsqueda en pill gris
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: TextField(
                controller: _searchController,
                cursorColor: const Color(0xFF5AB639),
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: '|',
                  hintStyle: const TextStyle(color: Color(0xFF888888)),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF888888),
                      size: 18,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botón lupa circular VERDE con borde blanco
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF5AB639),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF5AB639), width: 2),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: _filtros.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == _filtroSeleccionado;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filtroSeleccionado = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5AB639)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeccionCard(Map<String, dynamic> item) {
    final List<Map<String, dynamic>> tags = item['tags'];

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
          // ── Thumbnail de color sólido ─────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: item['imageColor'],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info central ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tags
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tag['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag['text'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tag['textColor'],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 5),

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
                const SizedBox(height: 3),

                // Capítulos
                Text(
                  item['capitulos'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),

                // Calificación y estudiantes
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Color(0xFFF6B55C)),
                    const SizedBox(width: 3),
                    Text(
                      item['calificacion'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const Text(
                      ' | ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                    Text(
                      '${item['estudiantes']} estudiantes',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Botones Editar / Eliminar con efecto press ────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Editar
              Material(
                color: const Color(0xFF5AB639),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    // acción editar
                  },
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  highlightColor: Colors.black.withValues(alpha: 0.12),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Editar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Botón Eliminar
              Material(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => _mostrarModalEliminar(item),
                  borderRadius: BorderRadius.circular(14),
                  splashColor: Colors.black.withValues(alpha: 0.18),
                  highlightColor: Colors.black.withValues(alpha: 0.12),
                  child: Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 13,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Eliminar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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

  void _mostrarModalEliminar(Map<String, dynamic> item) {
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
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título centrado
                const Center(
                  child: Text(
                    '¿Eliminar Lección?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Mensaje
                const Text(
                  'Tenga en cuenta que esta acción no se podrá revertir',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF49454F),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Simula la eliminación quitando el item de la lista
                        setState(() {
                          _lecciones.remove(item);
                        });
                      },
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(
                          color: Color(0xFF4DC130),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
