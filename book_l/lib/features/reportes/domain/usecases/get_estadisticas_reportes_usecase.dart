import '../../../../core/usecase/usecase.dart';
import '../entities/reporte.dart';
import '../repositories/reporte_repository.dart';

enum PeriodoFiltro { diario, semanal, mensual }

class GetEstadisticasReportesParams {
  final PeriodoFiltro periodo;

  GetEstadisticasReportesParams({required this.periodo});
}

class GetEstadisticasReportesUseCase
    implements UseCase<List<ReportePuntoChart>, GetEstadisticasReportesParams> {
  final ReporteRepository repository;

  GetEstadisticasReportesUseCase(this.repository);

  @override
  Future<List<ReportePuntoChart>> call(
      GetEstadisticasReportesParams params) async {
    final reportes = await repository.getReportes();

    if (reportes.isEmpty) return [];

    // Ordenar los reportes de forma ascendente
    reportes.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Fecha del último reporte como referencia (asumiendo que es el "hoy" de la app mockeada)
    // Para entornos reales usar DateTime.now()
    final maxDate = reportes.last.createdAt;

    switch (params.periodo) {
      case PeriodoFiltro.diario:
        return _agruparDiario(reportes, maxDate);
      case PeriodoFiltro.semanal:
        return _agruparSemanal(reportes, maxDate);
      case PeriodoFiltro.mensual:
        return _agruparMensual(reportes, maxDate);
    }
  }

  List<ReportePuntoChart> _agruparDiario(
      List<Reporte> reportes, DateTime maxDate) {
    // Mostramos los últimos 7 días
    final List<ReportePuntoChart> resultado = [];
    final List<String> diasCortos = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    for (int i = 6; i >= 0; i--) {
      // Fecha a consultar
      final targetDate = maxDate.subtract(Duration(days: i));

      // Contamos
      int count = reportes.where((r) {
        return r.createdAt.year == targetDate.year &&
            r.createdAt.month == targetDate.month &&
            r.createdAt.day == targetDate.day;
      }).length;

      // Label (Lun, Mar, Mie...)
      final label = diasCortos[targetDate.weekday - 1];

      resultado.add(ReportePuntoChart(
        label: label,
        dateMin: targetDate,
        dateMax: targetDate, // En diarios el min y max es el mismo
        cantidad: count,
      ));
    }

    return resultado;
  }

  List<ReportePuntoChart> _agruparSemanal(
      List<Reporte> reportes, DateTime maxDate) {
    // Mostramos las últimas 4 semanas
    final List<ReportePuntoChart> resultado = [];

    for (int i = 3; i >= 0; i--) {
      // Tomamos 7 días por bloque
      final endWindow = maxDate.subtract(Duration(days: i * 7));
      final startWindow = endWindow.subtract(const Duration(days: 6));

      int count = reportes.where((r) {
        // Ignoramos la hora para un rango más preciso
        final rDate = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
        final start = DateTime(startWindow.year, startWindow.month, startWindow.day);
        final end = DateTime(endWindow.year, endWindow.month, endWindow.day);
        
        return (rDate.isAfter(start) || rDate.isAtSameMomentAs(start)) &&
               (rDate.isBefore(end) || rDate.isAtSameMomentAs(end));
      }).length;

      resultado.add(ReportePuntoChart(
        label: 'Sem ${4 - i}', // Sem 1, Sem 2...
        dateMin: startWindow,
        dateMax: endWindow,
        cantidad: count,
      ));
    }

    return resultado;
  }

  List<ReportePuntoChart> _agruparMensual(
      List<Reporte> reportes, DateTime maxDate) {
    // Mostramos los últimos 6 meses
    final List<ReportePuntoChart> resultado = [];
    final mesesNombres = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    for (int i = 5; i >= 0; i--) {
      // Restar i meses (Manejando el cambio de año)
      DateTime targetMonth = DateTime(maxDate.year, maxDate.month - i, 1);
      
      int count = reportes.where((r) {
        return r.createdAt.year == targetMonth.year &&
               r.createdAt.month == targetMonth.month;
      }).length;

      resultado.add(ReportePuntoChart(
        label: mesesNombres[targetMonth.month - 1],
        dateMin: targetMonth,
        dateMax: targetMonth, // Solo interesa el mes y año
        cantidad: count,
      ));
    }

    return resultado;
  }
}
