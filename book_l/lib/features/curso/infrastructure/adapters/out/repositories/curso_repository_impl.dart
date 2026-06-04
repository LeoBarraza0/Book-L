import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/curso/application/ports/out/curso_repository.dart';
import 'package:book_l/features/curso/infrastructure/adapters/out/dtos/curso_dto.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/leccion_dto.dart';
import 'package:flutter/foundation.dart';

// Adaptador secundario — implementa el puerto definido en domain/repositories/.
class CursoRepositoryImpl implements CursoRepository {
  final BooklService _service;

  CursoRepositoryImpl(this._service);

  Map<String, dynamic> _toSupabaseMap(Curso curso) {
    return {
      if (curso.idCurso != 0) 'idcurso': curso.idCurso,
      'idusuariofk': curso.idUsuarioFk,
      'nombre': curso.nombre,
      'contenido': curso.contenido,
      'imagen_url': curso.imagenUrl,
      'tagcolor': curso.tagColor,
      'esnuevo': curso.esNuevo,
      'estado': curso.estado,
    };
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Curso>> getCursos() async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_curso').select();
        final cursosRaw = res.map((e) => CursoDto.fromJson(e)).toList();
        final cursos = cursosRaw.map((c) {
          final rating = _service.obtenerRatingCurso(c.idCurso);
          return c.copyWith(rating: rating);
        }).toList();
        
        // Sync local
        for (var c in cursos) {
          final idx = _service.cursos.indexWhere((lc) => lc.idCurso == c.idCurso);
          if (idx == -1) _service.cursos.add(c);
          else _service.cursos[idx] = c;
        }
        
        return cursos;
      } catch (e) {
        if (kDebugMode) print('Error getCursos Supabase: $e');
      }
    }
    return List.unmodifiable(_service.cursos);
  }

  @override
  Future<Curso?> getCursoById(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_curso').select().eq('idcurso', id).maybeSingle();
        if (res != null) {
          final c = CursoDto.fromJson(res);
          final rating = _service.obtenerRatingCurso(c.idCurso);
          return c.copyWith(rating: rating);
        }
      } catch (e) {
        if (kDebugMode) print('Error getCursoById Supabase: $e');
      }
    }
    try {
      return _service.cursos.firstWhere((c) => c.idCurso == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Leccion>> getLeccionesDeCurso(int idCurso) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_lecciones_cursos')
            .select('tbl_leccion(*)')
            .eq('idcurso', idCurso);
            
        final List<Leccion> lecciones = [];
        for (var r in res) {
          if (r['tbl_leccion'] != null) {
            final l = LeccionDto.fromJson(r['tbl_leccion']);
            final rating = _service.obtenerRatingLeccion(l.idLeccion);
            lecciones.add(l.copyWith(rating: rating));
          }
        }
        return lecciones;
      } catch (e) {
        if (kDebugMode) print('Error getLeccionesDeCurso Supabase: $e');
      }
    }
    
    final ids = _service.leccionesCursos
        .where((e) => e['id_curso'] == idCurso)
        .map((e) => e['id_leccion']!)
        .toSet();

    return _service.lecciones.where((l) => ids.contains(l.idLeccion)).toList();
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> addCurso(Curso curso) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_curso')
            .insert(_toSupabaseMap(curso))
            .select()
            .single();
        final insertado = CursoDto.fromJson(res);
        _service.addCurso(insertado);
        return;
      } catch (e) {
        if (kDebugMode) print('Error addCurso Supabase: $e');
      }
    }
    final nuevo = curso.copyWith(idCurso: _service.nextCursoId());
    _service.addCurso(nuevo);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCurso(Curso curso) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_curso')
            .update(_toSupabaseMap(curso))
            .eq('idcurso', curso.idCurso);
        _service.updateCurso(curso);
        return;
      } catch (e) {
        if (kDebugMode) print('Error updateCurso Supabase: $e');
      }
    }
    _service.updateCurso(curso);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCurso(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_curso').delete().eq('idcurso', id);
        _service.removeCurso(id);
        return;
      } catch (e) {
        if (kDebugMode) print('Error deleteCurso Supabase: $e');
      }
    }
    _service.removeCurso(id);
  }

  // ── PIVOTE M:N ────────────────────────────────────────────────────────────

  @override
  Future<void> asociarLeccion(int idCurso, int idLeccion) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client.from('tbl_lecciones_cursos').insert({
          'idcurso': idCurso,
          'idleccion': idLeccion,
        });
        _service.asociarLeccion(idCurso, idLeccion);
        return;
      } catch (e) {
        if (kDebugMode) print('Error asociarLeccion Supabase: $e');
      }
    }
    _service.asociarLeccion(idCurso, idLeccion);
  }

  @override
  Future<void> desasociarLeccion(int idCurso, int idLeccion) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_lecciones_cursos')
            .delete()
            .eq('idcurso', idCurso)
            .eq('idleccion', idLeccion);
        _service.desasociarLeccion(idCurso, idLeccion);
        return;
      } catch (e) {
        if (kDebugMode) print('Error desasociarLeccion Supabase: $e');
      }
    }
    _service.desasociarLeccion(idCurso, idLeccion);
  }
}
