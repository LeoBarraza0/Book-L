import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/widgets/nav_bar.dart';

import '../controller/admin_home_controller.dart';
import '../controller/admin_home_state.dart';
import '../../../reportes/domain/entities/reporte.dart';
import '../../../reportes/domain/usecases/get_estadisticas_reportes_usecase.dart';
import '../../../reportes/data/repositories/reportes_repository_impl.dart';

AdminHomeController _buildController() {
  final repo = ReportesRepositoryImpl();
  final usecase = GetEstadisticasReportesUseCase(repo);
  return AdminHomeController(getEstadisticasReportes: usecase);
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late final AdminHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _controller.cargarDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40), // Top safe area spacing
                      _buildHeader(context),
                      const SizedBox(height: 30),
                      _buildQuickActionsGrid(context),
                      const SizedBox(height: 30),
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) => _buildActividadSection(),
                      ),
                      const SizedBox(height: 30),
                      _buildNovedadesSection(),
                      const SizedBox(height: 100), // Bottom nav space
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SharedBottomNavBar(selectedIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        SvgPicture.asset(
          'assets/images/logo.svg',
          height: 50,
          fit: BoxFit.contain,
        ),
        // Notification bell
        GestureDetector(
          onTap: () {},
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
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _buildActionCard(
          context,
          title: 'Reportes',
          color: const Color(0xFFFD5C63),
          icon: Icons.error_outline,
          onTap: () => Navigator.pushNamed(context, '/reportes'),
        ),
        _buildActionCard(
          context,
          title: 'Lecciones',
          color: const Color(0xFF4EBE59),
          icon: Icons.menu_book,
          onTap: () => Navigator.pushNamed(context, '/admin_leccion'),
        ),
        _buildActionCard(context,
            title: 'Usuarios',
            color: const Color(0xFFFFB84E),
            icon: Icons.person_outline,
            onTap: () => Navigator.pushNamed(context, '/users_admin')),
        _buildActionCard(
          context,
          title: 'Configuración',
          color: const Color(0xFF6D6E71),
          icon: Icons.settings_outlined,
          onTap: () => Navigator.pushNamed(context, '/configuracion'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.black.withValues(alpha: 0.15),
        highlightColor: Colors.black.withValues(alpha: 0.10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 48),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_outward, color: color, size: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActividadSection() {
    final state = _controller.state;
    List<ReportePuntoChart> chartData = [];
    PeriodoFiltro currentFiltro = _controller.periodoActual;

    if (state is AdminHomeLoaded) {
      chartData = state.chartData;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Actividad (Reportes)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: state is AdminHomeLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4DC130)))
              : state is AdminHomeError
                  ? Center(
                      child: Text(
                        'Error al cargar',
                        style: TextStyle(color: Colors.red.shade300),
                      ),
                    )
                  : CustomPaint(
                      painter: _LineChartPainter(chartData),
                    ),
        ),
        const SizedBox(height: 16),
        // BOTONES DE FILTRO ESTILO DASHBOARD PREMIUM
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartFilterButton('Diarios', PeriodoFiltro.diario, currentFiltro),
            const SizedBox(width: 8),
            _buildChartFilterButton('Semanales', PeriodoFiltro.semanal, currentFiltro),
            const SizedBox(width: 8),
            _buildChartFilterButton('Mensuales', PeriodoFiltro.mensual, currentFiltro),
          ],
        ),
      ],
    );
  }

  Widget _buildChartFilterButton(
      String label, PeriodoFiltro targetFiltro, PeriodoFiltro currentFiltro) {
    final isSelected = targetFiltro == currentFiltro;
    return GestureDetector(
      onTap: () => _controller.cambiarPeriodo(targetFiltro),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DC130) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4DC130).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF676767),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNovedadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Novedades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildNovedadCard(
          tagLabel: 'Cálculo diferencial',
          tagColor: const Color(0xFF4EBE59),
          title: 'Derivadas',
          subtitle: '1 Hora | 4.9 | 1.200 estudiantes',
        ),
        const SizedBox(height: 12),
        _buildNovedadCard(
          tagLabel: 'Álgebra lineal',
          tagColor: const Color(0xFFF6B55C),
          title: 'Matrices',
          subtitle: '2 Horas | 4.8 | 800 estudiantes',
        ),
      ],
    );
  }

  Widget _buildNovedadCard({
    required String tagLabel,
    required Color tagColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail Placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.class_outlined, color: Colors.black26),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tagLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF676767),
                  ),
                ),
              ],
            ),
          ),
          // Actions / Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(
                Icons.favorite_border,
                color: Color(0xFFFF606F),
                size: 20,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFF6B55C), size: 14),
                  SizedBox(width: 4),
                  Text(
                    '4.9',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

class _LineChartPainter extends CustomPainter {
  final List<ReportePuntoChart> data;

  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    int horizontalLines = 4;
    // Líneas horizontales de guía
    for (int i = 0; i <= horizontalLines; i++) {
      double y = size.height * (i / horizontalLines);
      for (double x = 0; x < size.width; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y), gridPaint);
      }
    }

    int maxVal = data.map((e) => e.cantidad).reduce(max);
    if (maxVal == 0) maxVal = 1; // Prevenir division por 0

    // Para evitar que los puntos toquen los costados, agreamos padding interno
    final innerPaddingX = 20.0;
    final availableWidth = size.width - (innerPaddingX * 2);
    final spacingX = data.length > 1 ? availableWidth / (data.length - 1) : availableWidth;

    List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final val = data[i].cantidad;
      // Invertir Y porque 0 está arriba en el canvas
      double x = innerPaddingX + (i * spacingX);
      
      // Dejamos 20% despacio en Y para no golpear el techo
      final realHeight = size.height * 0.8;
      double y = size.height - (realHeight * (val / maxVal));

      // Si es un solo punto, lo dibujamos en el centro
      if (data.length == 1) {
        x = size.width / 2;
      }
      points.add(Offset(x, y));

      // Dibujar Label (Lun, Mar, Sem, etc) en la parte de abajo
      textPainter.text = TextSpan(
        text: data[i].label,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), size.height - 18), // Movido mas arriba pq se cortaba
      );
      
      // Dibujar valor encima del punto principal
      if (val > 0) {
        textPainter.text = TextSpan(
          text: val.toString(),
          style: const TextStyle(
            color: Color(0xFF4DC130),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - (textPainter.width / 2), y - 20),
        );
      }
    }

    final linePaint = Paint()
      ..color = const Color(0xFF4DC130)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);

      // Sombreado bajo la línea
      final fillPaint = Paint()
        ..color = const Color(0xFF4DC130).withValues(alpha: 0.1)
        ..style = PaintingStyle.fill;
      final fillPath = Path.from(path);
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.lineTo(points.first.dx, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
    }

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderDotPaint = Paint()
      ..color = const Color(0xFF4DC130)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 5, borderDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
