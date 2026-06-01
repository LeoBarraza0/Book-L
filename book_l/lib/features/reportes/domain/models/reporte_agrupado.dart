class ReporteAgrupado {
  final int idEntidad;
  final String nombreEntidad;
  final String tipoEntidad;
  final int cantidadReportes;
  final DateTime? ultimaFechaReporte;

  ReporteAgrupado({
    required this.idEntidad,
    required this.nombreEntidad,
    required this.tipoEntidad,
    required this.cantidadReportes,
    this.ultimaFechaReporte,
  });
}
