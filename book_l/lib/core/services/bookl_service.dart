import 'dart:convert';
import 'package:flutter/services.dart';

import '../../features/curso/data/dto/curso_dto.dart';
import '../../features/curso/domain/entities/curso.dart';
import '../../features/leccion/data/dto/capitulo_dto.dart';
import '../../features/leccion/data/dto/leccion_dto.dart';
import '../../features/leccion/data/dto/material_dto.dart';
import '../../features/leccion/domain/entities/capitulo.dart';
import '../../features/leccion/domain/entities/leccion.dart';
import '../../features/leccion/domain/entities/material_educativo.dart';

// Servicio central de datos JSON — Singleton de uso restringido.
//
// REGLA DE USO: Solo los repository_impl pueden importar este servicio.
// Nunca importarlo directamente desde presentation/ ni desde domain/.
//
// Actúa como "base de datos en memoria" hasta migrar a API REST.
class BooklService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BooklService _instance = BooklService._internal();
  factory BooklService() => _instance;
  BooklService._internal();

  // ── Estado ─────────────────────────────────────────────────────────────────
  bool _loaded = false;

  // ── "Tablas" en memoria ────────────────────────────────────────────────────
  List<Curso> cursos = [];
  List<Leccion> lecciones = [];
  List<Capitulo> capitulos = [];
  List<MaterialEducativo> materiales = [];

  // Pivote M:N lecciones ↔ cursos
  // Cada elemento es { 'id_leccion': int, 'id_curso': int }
  List<Map<String, int>> leccionesCursos = [];

  // ── Inicialización (llamar una sola vez desde main.dart) ───────────────────
  Future<void> init() async {
    if (_loaded) return;

    final raw = await rootBundle.loadString('assets/data/bookl_data.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    cursos = (data['cursos'] as List)
        .map((e) => CursoDto.fromJson(e as Map<String, dynamic>))
        .toList();

    lecciones = (data['lecciones'] as List)
        .map((e) => LeccionDto.fromJson(e as Map<String, dynamic>))
        .toList();

    capitulos = (data['capitulos'] as List)
        .map((e) => CapituloDto.fromJson(e as Map<String, dynamic>))
        .toList();

    materiales = (data['materiales'] as List)
        .map((e) => MaterialDto.fromJson(e as Map<String, dynamic>))
        .toList();

    leccionesCursos = (data['lecciones_cursos'] as List)
        .map((e) => {
              'id_leccion': e['id_leccion'] as int,
              'id_curso': e['id_curso'] as int,
            })
        .toList();

    _loaded = true;
  }

  // ── Generador de IDs ───────────────────────────────────────────────────────
  int _nextId(List<dynamic> list, int Function(dynamic) getId) {
    if (list.isEmpty) return 1;
    return list.map(getId).reduce((a, b) => a > b ? a : b) + 1;
  }

  int nextCursoId() => _nextId(cursos, (c) => (c as Curso).idCurso);
  int nextLeccionId() => _nextId(lecciones, (l) => (l as Leccion).idLeccion);
  int nextCapituloId() =>
      _nextId(capitulos, (c) => (c as Capitulo).idCapitulo);
}
