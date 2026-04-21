class Reporte {
  final int idReporte;
  final int idUsuarioFk;
  final String entidadTipo;
  final int entidadId;
  final String motivo;
  final DateTime createdAt;

  Reporte({
    required this.idReporte,
    required this.idUsuarioFk,
    required this.entidadTipo,
    required this.entidadId,
    required this.motivo,
    required this.createdAt,
  });
}

class ReportePuntoChart {
  final String label; // e.g: "Lun", "Mar", "Semana 1", "Ene"
  final DateTime dateMin;
  final DateTime dateMax;
  final int cantidad;

  ReportePuntoChart({
    required this.label,
    required this.dateMin,
    required this.dateMax,
    required this.cantidad,
  });
}
