import 'package:flutter/material.dart';
import '../../../../shared/widgets/nav_bar.dart';
import '../widgets/reporte_card.dart';
import '../../../../core/services/bookl_service.dart' as bookl;

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Todas', 'Recientes', 'N° Reportes', '...'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFECEBEB),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 16),
                // Filters
                _buildFilters(),
                const SizedBox(height: 24),
                // Report List
                _buildReportList(),
                const SizedBox(height: 120), // Espacio para el navbar flotante
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: SharedBottomNavBar(selectedIndex: 3, role: 'admin'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Transform.scale(
      scaleX: 1.02, // Evita lineas blancas laterales de antialiasing
      child: Container(
        width: screenWidth,
        height: 230,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/red_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            // Title
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Reportes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                hintText: '|',
                hintStyle: const TextStyle(color: Colors.black54),
                suffixIcon: IconButton(
                  icon:
                      const Icon(Icons.close, size: 20, color: Colors.black54),
                  onPressed: () => _searchController.clear(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 44,
          width: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF5AB639),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5AB639)
                    : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportList() {
    return ListenableBuilder(
      listenable: bookl.BooklService(),
      builder: (context, _) {
        final service = bookl.BooklService();
        final reportesReales = service.reportes;

        if (reportesReales.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No hay contenido reportado aún.'),
          );
        }

        // Agrupar los reportes por tipo y id: "Curso-1"
        final reportCounts = <String, int>{};
        for (var r in reportesReales) {
          final key = '${r['entidad_tipo']}-${r['entidad_id']}';
          reportCounts[key] = (reportCounts[key] ?? 0) + 1;
        }

        final List<Map<String, dynamic>> reportItems = [];

        // Generar items solo para los que tienen reportes
        for (var key in reportCounts.keys) {
          final parts = key.split('-');
          final String tipo = parts[0];
          final int id = int.tryParse(parts[1]) ?? 0;
          final int count = reportCounts[key]!;

          String nombre = 'Elemento Desconocido';
          Color boxColor = const Color(0xFFD9D9D9);

          if (tipo == 'Curso') {
            final curso = service.cursos.where((c) => c.idCurso == id).firstOrNull;
            if (curso != null) nombre = curso.nombre;
            boxColor = const Color(0xFFFF606F);
          } else if (tipo == 'Lección') {
            final leccion = service.lecciones.where((l) => l.idLeccion == id).firstOrNull;
            if (leccion != null) nombre = leccion.nombre;
            boxColor = const Color(0xFF5AB639);
          } else if (tipo == 'Capítulo') {
            final capitulo = service.capitulos.where((c) => c.idCapitulo == id).firstOrNull;
            if (capitulo != null) nombre = capitulo.nombre;
            boxColor = const Color(0xFFFFB800);
          }

          reportItems.add({
            'id': id,
            'nombre': nombre,
            'tipo': tipo,
            'tag': tipo,
            'boxColor': boxColor,
            'reportCount': count,
          });
        }

        return Column(
          children: reportItems.map((item) {
            return ReporteCard(
              title: item['nombre'],
              subtitle: item['tipo'],
              rating: 4.9,
              reportCount: item['reportCount'],
              tags: [item['tag']],
              boxColor: item['boxColor'],
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  '/reporte_detail',
                  arguments: {
                    'id_leccion': item['id'],
                    'nombre': item['nombre'],
                    'tipo': item['tipo'],
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }


}
