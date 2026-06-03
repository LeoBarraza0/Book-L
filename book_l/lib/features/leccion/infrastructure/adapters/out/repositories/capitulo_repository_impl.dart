import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/application/ports/out/capitulo_repository.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/capitulo_dto.dart';
import 'package:flutter/foundation.dart';

class CapituloRepositoryImpl implements CapituloRepository {
  final BooklService _service;

  CapituloRepositoryImpl(this._service);

  Map<String, dynamic> _toSupabaseMap(Capitulo capitulo) {
    return {
      if (capitulo.idCapitulo != 0) 'idcapitulo': capitulo.idCapitulo,
      'idleccion': capitulo.idLeccion,
      'nombre': capitulo.nombre,
      'contenido': capitulo.contenido,
      'tiempo_total': capitulo.tiempoTotal,
    };
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Capitulo>> getCapitulos() async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_capitulo').select();
        final capitulos = res.map((e) => CapituloDto.fromJson(e)).toList();
        
        for (var c in capitulos) {
          final idx = _service.capitulos.indexWhere((lc) => lc.idCapitulo == c.idCapitulo);
          if (idx == -1) _service.capitulos.add(c);
          else _service.capitulos[idx] = c;
        }
        
        return capitulos;
      } catch (e) {
        if (kDebugMode) print('Error getCapitulos Supabase: $e');
      }
    }
    return List.unmodifiable(_service.capitulos);
  }

  @override
  Future<Capitulo?> getCapituloById(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_capitulo').select().eq('idcapitulo', id).maybeSingle();
        if (res != null) {
          return CapituloDto.fromJson(res);
        }
      } catch (e) {
        if (kDebugMode) print('Error getCapituloById Supabase: $e');
      }
    }
    try {
      return _service.capitulos.firstWhere((c) => c.idCapitulo == id);
    } catch (_) {
      return null;
    }
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<int> addCapitulo(Capitulo capitulo) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_capitulo')
            .insert(_toSupabaseMap(capitulo))
            .select()
            .single();
        final insertado = CapituloDto.fromJson(res);
        _service.addCapitulo(insertado);
        return insertado.idCapitulo;
      } catch (e) {
        if (kDebugMode) print('Error addCapitulo Supabase: $e');
      }
    }
    final newId = _service.nextCapituloId();
    final nuevo = capitulo.copyWith(idCapitulo: newId);
    _service.addCapitulo(nuevo);
    return newId;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCapitulo(Capitulo capitulo) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_capitulo')
            .update(_toSupabaseMap(capitulo))
            .eq('idcapitulo', capitulo.idCapitulo);
        _service.updateCapitulo(capitulo);
        return;
      } catch (e) {
        if (kDebugMode) print('Error updateCapitulo Supabase: $e');
      }
    }
    _service.updateCapitulo(capitulo);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCapitulo(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_capitulo').delete().eq('idcapitulo', id);
        _service.removeCapitulo(id);
        return;
      } catch (e) {
        if (kDebugMode) print('Error deleteCapitulo Supabase: $e');
      }
    }
    _service.removeCapitulo(id);
  }
}
