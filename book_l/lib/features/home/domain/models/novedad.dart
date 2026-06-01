import 'package:flutter/material.dart';

class Novedad {
  final int idEntidad;
  final String titulo;
  final String tipo; // "Curso", "Lección", "Capítulo"
  final String autorNombre;
  final DateTime fechaPublicacion;
  final Color colorTema;

  Novedad({
    required this.idEntidad,
    required this.titulo,
    required this.tipo,
    required this.autorNombre,
    required this.fechaPublicacion,
    required this.colorTema,
  });

  /// Retorna una etiqueta relativa de tiempo (ej. "Hace 2 días")
  String get fechaRelativa {
    final ahora = DateTime.now();
    final diff = ahora.difference(fechaPublicacion);

    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return 'Hace $years ${years == 1 ? 'año' : 'años'}';
    } else if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return 'Hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (diff.inDays >= 1) {
      return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
    } else if (diff.inHours >= 1) {
      return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    } else {
      return 'Hace unos minutos';
    }
  }
}
