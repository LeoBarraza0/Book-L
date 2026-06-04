import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/domain/models/material_educativo.dart';
import 'package:book_l/features/leccion/application/ports/out/leccion_repository.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/leccion_dto.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/capitulo_dto.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/material_dto.dart';
import 'package:flutter/foundation.dart';

class LeccionRepositoryImpl implements LeccionRepository {
  final BooklService _service;

  LeccionRepositoryImpl(this._service);

  Map<String, dynamic> _toSupabaseMap(Leccion leccion) {
    return {
      if (leccion.idLeccion != 0) 'idleccion': leccion.idLeccion,
      'idusuariofk': leccion.idUsuarioFk,
      'nombre': leccion.nombre,
      'contenido': leccion.contenido,
      'imagen_url': leccion.imagenUrl,
      'tagcolor': leccion.tagColor,
      'esnuevo': leccion.esNuevo,
      'estado': leccion.estado,
    };
  }

  Map<String, dynamic> _materialToSupabaseMap(MaterialEducativo m) {
    return {
      if (m.idMaterial != 0) 'idmaterial': m.idMaterial,
      'idleccionfk': m.idLeccionFk,
      'nombre': m.nombre,
      'url': m.url,
      'descripcion': m.descripcion,
      'tipo': m.tipo,
      'tamano_bytes': m.tamanoBytes,
    };
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Leccion>> getLecciones() async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res =
            await SupabaseClientHelper.client.from('tbl_leccion').select();
        final leccionesRaw = res.map((e) => LeccionDto.fromJson(e)).toList();
        final lecciones = leccionesRaw.map((l) {
          final rating = _service.obtenerRatingLeccion(l.idLeccion);
          return l.copyWith(rating: rating);
        }).toList();

        for (var l in lecciones) {
          final idx = _service.lecciones
              .indexWhere((ll) => ll.idLeccion == l.idLeccion);
          if (idx == -1)
            _service.lecciones.add(l);
          else
            _service.lecciones[idx] = l;
        }

        return lecciones;
      } catch (e) {
        if (kDebugMode) print('Error getLecciones Supabase: $e');
      }
    }
    return List.unmodifiable(_service.lecciones);
  }

  @override
  Future<Leccion?> getLeccionById(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_leccion')
            .select()
            .eq('idleccion', id)
            .maybeSingle();
        if (res != null) {
          final l = LeccionDto.fromJson(res);
          final rating = _service.obtenerRatingLeccion(l.idLeccion);
          return l.copyWith(rating: rating);
        }
      } catch (e) {
        if (kDebugMode) print('Error getLeccionById Supabase: $e');
      }
    }
    try {
      return _service.lecciones.firstWhere((l) => l.idLeccion == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Capitulo>> getCapitulosDeLeccion(int idLeccion) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_capitulo')
            .select()
            .eq('idleccion', idLeccion);
        return res.map((e) => CapituloDto.fromJson(e)).toList();
      } catch (e) {
        if (kDebugMode) print('Error getCapitulosDeLeccion Supabase: $e');
      }
    }
    return _service.capitulos.where((c) => c.idLeccion == idLeccion).toList();
  }

  /// Devuelve capítulos de forma síncrona (ya cargados en memoria)
  @override
  List<Capitulo> capitulosDe(int idLeccion) =>
      _service.capitulos.where((c) => c.idLeccion == idLeccion).toList();

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<int> addLeccion(Leccion leccion) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client
            .from('tbl_leccion')
            .insert(_toSupabaseMap(leccion))
            .select()
            .single();
        final insertada = LeccionDto.fromJson(res);
        final rating = _service.obtenerRatingLeccion(insertada.idLeccion);
        final insertadaConRating = insertada.copyWith(rating: rating);
        _service.addLeccion(insertadaConRating);
        return insertada.idLeccion;
      } catch (e) {
        if (kDebugMode) print('Error addLeccion Supabase: $e');
      }
    }
    final newId = _service.nextLeccionId();
    final nueva = leccion.copyWith(idLeccion: newId);
    _service.addLeccion(nueva);
    return newId;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateLeccion(Leccion leccion) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_leccion')
            .update(_toSupabaseMap(leccion))
            .eq('idleccion', leccion.idLeccion);
        _service.updateLeccion(leccion);
        return;
      } catch (e) {
        if (kDebugMode) print('Error updateLeccion Supabase: $e');
      }
    }
    _service.updateLeccion(leccion);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteLeccion(int id) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        await SupabaseClientHelper.client
            .from('tbl_leccion')
            .delete()
            .eq('idleccion', id);
        _service.removeLeccion(id);
        return;
      } catch (e) {
        if (kDebugMode) print('Error deleteLeccion Supabase: $e');
      }
    }
    _service.removeLeccion(id);
  }

  // ── Material Educativo ─────────────────────────────────────────────────────

  @override
  List<MaterialEducativo> materialesDeLeccion(int idLeccion) =>
      _service.materialesDeLeccion(idLeccion);

  @override
  int agregarMaterial(MaterialEducativo material) {
    final tempId = _service.nextMaterialId();
    final nuevo = material.copyWith(idMaterial: tempId);
    _service.addMaterial(nuevo, syncToSupabase: false);

    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client
          .from('tbl_material')
          .insert(_materialToSupabaseMap(material))
          .select()
          .single()
          .then((res) {
        final insertado = MaterialDto.fromJson(res);
        _service.replaceMaterial(tempId, insertado);
      }).catchError((e) {
        if (kDebugMode) print('Error agregarMaterial Supabase: $e');
      });
    }
    return tempId;
  }

  @override
  void actualizarMaterial(MaterialEducativo material) {
    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client
          .from('tbl_material')
          .update(_materialToSupabaseMap(material))
          .eq('idmaterial', material.idMaterial)
          .catchError((e) {
        if (kDebugMode) print('Error actualizarMaterial Supabase: $e');
      });
    }
    _service.updateMaterial(material, syncToSupabase: false);
  }

  @override
  void eliminarMaterial(int idMaterial) {
    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client
          .from('tbl_material')
          .delete()
          .eq('idmaterial', idMaterial)
          .catchError((e) {
        if (kDebugMode) print('Error eliminarMaterial Supabase: $e');
      });
    }
    _service.removeMaterial(idMaterial, syncToSupabase: false);
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  @override
  int generarId() => _service.generateId();

  @override
  dynamic getUsuarioById(int idUsuario) {
    try {
      return _service.usuarios.firstWhere((u) => u.idUsuario == idUsuario);
    } catch (_) {
      return null;
    }
  }

  @override
  List<dynamic> getCursosAsociados(int idLeccion) {
    final asociadosIds = _service.leccionesCursos
        .where((e) => e['id_leccion'] == idLeccion)
        .map((e) => e['id_curso'])
        .toList();
    return _service.cursos
        .where((c) => asociadosIds.contains(c.idCurso))
        .toList();
  }
}
