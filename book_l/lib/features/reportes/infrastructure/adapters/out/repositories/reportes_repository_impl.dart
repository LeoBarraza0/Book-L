import 'package:book_l/features/reportes/domain/models/reporte_agrupado.dart';

import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/reportes/domain/models/reporte.dart';
import 'package:book_l/features/reportes/application/ports/out/reporte_repository.dart';
import 'package:book_l/features/reportes/infrastructure/adapters/out/dtos/reporte_dto.dart';
import 'package:flutter/foundation.dart';

class ReportesRepositoryImpl implements ReporteRepository {
  @override
  Future<List<Reporte>> getReportes() async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_reporte').select();
        return res.map<Reporte>((e) => ReporteDto.fromJson(e).toEntity()).toList();
      } catch (e) {
        if (kDebugMode) print('Error getReportes Supabase: $e');
      }
    }

    // Fallback: Obtenemos los mapas desde la "base de datos" simulada
    final List<Map<String, dynamic>> rawData = BooklService().reportes;
    try {
      final List<Reporte> reportes = rawData
          .map<Reporte>((e) => ReporteDto.fromJson(e).toEntity())
          .toList();
      return reportes;
    } catch (e) {
      throw Exception('Error al parsear reportes: $e');
    }
  }

  @override
  Future<List<ReporteAgrupado>> getReportesAgrupados() async {
    final reportesReales = <Map<String, dynamic>>[];
    
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_reporte').select();
        reportesReales.addAll(res);
      } catch (e) {
        if (kDebugMode) print('Error getReportesAgrupados Supabase: $e');
        reportesReales.addAll(BooklService().reportes);
      }
    } else {
      reportesReales.addAll(BooklService().reportes);
    }

    if (reportesReales.isEmpty) return [];

    final reportCounts = <String, int>{};
    final reportTypeMap = <String, String>{};
    final reportDateMap = <String, DateTime>{};

    for (var r in reportesReales) {
      final String tipo = r['entidad_tipo']?.toString() ?? 'Desconocido';
      final int id = r['entidad_id'] is int
          ? r['entidad_id']
          : int.tryParse(r['entidad_id']?.toString() ?? '0') ?? 0;

      DateTime rDate = DateTime.now();
      if (r['created_at'] != null) {
        rDate = DateTime.tryParse(r['created_at'].toString()) ?? rDate;
      }

      final key = '${tipo.toLowerCase().replaceAll('ó', 'o')}-$id';
      reportCounts[key] = (reportCounts[key] ?? 0) + 1;
      reportTypeMap[key] = tipo;

      if (!reportDateMap.containsKey(key) ||
          rDate.isAfter(reportDateMap[key]!)) {
        reportDateMap[key] = rDate;
      }
    }

    final service = BooklService();
    final List<ReporteAgrupado> resultado = [];

    for (var key in reportCounts.keys) {
      final parts = key.split('-');
      final String normalizedTipo = parts[0];
      final int id = int.tryParse(parts[1]) ?? 0;
      final int count = reportCounts[key]!;
      final String originalTipo = reportTypeMap[key]!;
      final DateTime? ultimaFecha = reportDateMap[key];

      String nombre = 'Elemento Desconocido';

      if (normalizedTipo == 'curso') {
        final curso = service.cursos.where((c) => c.idCurso == id).firstOrNull;
        if (curso != null) nombre = curso.nombre;
      } else if (normalizedTipo == 'leccion') {
        final leccion =
            service.lecciones.where((l) => l.idLeccion == id).firstOrNull;
        if (leccion != null) nombre = leccion.nombre;
      } else if (normalizedTipo == 'capitulo') {
        final capitulo =
            service.capitulos.where((c) => c.idCapitulo == id).firstOrNull;
        if (capitulo != null) nombre = capitulo.nombre;
      }

      resultado.add(ReporteAgrupado(
        idEntidad: id,
        nombreEntidad: nombre,
        tipoEntidad: originalTipo,
        cantidadReportes: count,
        ultimaFechaReporte: ultimaFecha,
      ));
    }

    return resultado;
  }

  @override
  Future<List<Reporte>> getReportesPorEntidad(String tipo, int id) async {
    final allReportes = await getReportes();

    final normalizedSearchType = tipo.toLowerCase().replaceAll('ó', 'o');

    return allReportes.where((r) {
      final rTipo = r.entidadTipo.toLowerCase().replaceAll('ó', 'o');
      return rTipo == normalizedSearchType && r.entidadId == id;
    }).toList();
  }

  @override
  Future<void> addReporte({
    required int idUsuarioFk,
    required String entidadTipo,
    required int entidadId,
    required String motivo,
  }) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_reporte').insert({
          'idusuariofk': idUsuarioFk,
          'entidad_tipo': entidadTipo,
          'entidad_id': entidadId,
          'motivo': motivo,
        });
      } catch (e) {
        if (kDebugMode) print('Error addReporte Supabase: $e');
      }
    }
    BooklService().addReporte(
      idUsuarioFk: idUsuarioFk,
      entidadTipo: entidadTipo,
      entidadId: entidadId,
      motivo: motivo,
    );
  }
}
