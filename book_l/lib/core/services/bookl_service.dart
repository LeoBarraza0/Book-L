import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/data/dto/usuario_dto.dart';
import '../../features/auth/domain/entities/usuario.dart';
import '../../features/curso/data/dto/curso_dto.dart';
import '../../features/curso/domain/entities/curso.dart';
import '../../features/leccion/data/dto/capitulo_dto.dart';
import '../../features/leccion/data/dto/leccion_dto.dart';
import '../../features/leccion/data/dto/material_dto.dart';
import '../../features/leccion/domain/entities/capitulo.dart';
import '../../features/leccion/domain/entities/leccion.dart';
import '../../features/leccion/domain/entities/material_educativo.dart';
import '../../features/configuracion/data/dto/configuracion_dto.dart';
import '../../features/configuracion/domain/entities/configuracion.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Servicio central de datos JSON — Singleton de uso restringido.
//
// REGLA DE USO: Solo los repository_impl pueden importar este servicio.
// Nunca importarlo directamente desde presentation/ ni desde domain/.
//
// Actúa como "base de datos en memoria" hasta migrar a API REST.
class BooklService extends ChangeNotifier {
  static const String _storageKey = 'bookl_full_data';
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BooklService _instance = BooklService._internal();
  factory BooklService() => _instance;
  BooklService._internal();

  void notifyDataChanged() {
    notifyListeners();
  }

  // ── Estado ─────────────────────────────────────────────────────────────────
  bool _loaded = false;

  // ── "Tablas" en memoria ────────────────────────────────────────────────────
  List<UsuarioDto> usuariosDto = []; // con contraseña — solo para auth
  List<Usuario> usuarios = [];       // sin contraseña — exposición pública
  List<Curso> cursos = [];
  List<Leccion> lecciones = [];
  List<Capitulo> capitulos = [];
  List<MaterialEducativo> materiales = [];
  List<Configuracion> configuraciones = [];
  List<Map<String, dynamic>> sugerencias = [];

  // Pivote M:N lecciones ↔ cursos
  // Cada elemento es { 'id_leccion': int, 'id_curso': int }
  List<Map<String, int>> leccionesCursos = [];

  // ── Inicialización (llamar una sola vez desde main.dart) ───────────────────
  Future<void> init() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString(_storageKey);

    Map<String, dynamic> data;
    if (localData != null && localData.isNotEmpty) {
      data = json.decode(localData);
    } else {
      final raw = await rootBundle.loadString('assets/data/bookl_data.json');
      data = json.decode(raw);
    }

    usuariosDto = (data['usuarios'] as List)
        .map((e) => UsuarioDto.fromJson(e as Map<String, dynamic>))
        .toList();
    usuarios = usuariosDto.map((d) => d.toEntity()).toList();

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

    if (data.containsKey('configuraciones')) {
      final configDtos = (data['configuraciones'] as List)
          .map((e) => ConfiguracionDto.fromJson(e as Map<String, dynamic>))
          .toList();
      configuraciones = configDtos.map((d) => d.toEntity()).toList();
    } else {
      configuraciones = [];
    }

    leccionesCursos = (data['lecciones_cursos'] as List)
        .map((e) => {
              'id_leccion': e['id_leccion'] as int,
              'id_curso': e['id_curso'] as int,
            })
        .toList();

    if (data.containsKey('sugerencias')) {
      sugerencias = List<Map<String, dynamic>>.from(data['sugerencias']);
    } else {
      sugerencias = [];
    }

    _loaded = true;
    notifyListeners();
  }

  // ── Persistencia ───────────────────────────────────────────────────────────
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullData = {
        'usuarios': usuariosDto.map((u) => u.toJson()).toList(),
        'cursos': cursos.map((c) => CursoDto.toJson(c)).toList(),
        'lecciones': lecciones.map((l) => LeccionDto.toJson(l)).toList(),
        'capitulos': capitulos.map((c) => CapituloDto.toJson(c)).toList(),
        'materiales': materiales.map((m) => MaterialDto.toJson(m)).toList(),
        'configuraciones': configuraciones.map((c) => ConfiguracionDto.fromEntity(c).toJson()).toList(),
        'sugerencias': sugerencias,
        'lecciones_cursos': leccionesCursos,
      };
      await prefs.setString(_storageKey, json.encode(fullData));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error saving central data: $e");
    }
  }

  // ── Operaciones de Escritura ───────────────────────────────────────────────
  void addCurso(Curso curso) {
    cursos.add(curso);
    _save();
  }

  void addLeccion(Leccion leccion, {int? idCurso}) {
    lecciones.add(leccion);
    if (idCurso != null) {
      leccionesCursos.add({
        'id_leccion': leccion.idLeccion,
        'id_curso': idCurso,
      });
    }
    _save();
  }

  void addCapitulo(Capitulo capitulo) {
    capitulos.add(capitulo);
    _save();
  }

  void updateCurso(Curso curso) {
    final idx = cursos.indexWhere((c) => c.idCurso == curso.idCurso);
    if (idx != -1) {
      cursos[idx] = curso;
      _save();
    }
  }

  void removeCurso(int id) {
    cursos.removeWhere((c) => c.idCurso == id);
    // Eliminar también relaciones
    leccionesCursos.removeWhere((lc) => lc['id_curso'] == id);
    _save();
  }

  void removeLeccion(int id) {
    lecciones.removeWhere((l) => l.idLeccion == id);
    leccionesCursos.removeWhere((lc) => lc['id_leccion'] == id);
    _save();
  }

  void removeCapitulo(int id) {
    capitulos.removeWhere((c) => c.idCapitulo == id);
    _save();
  }

  void saveConfiguracion(Configuracion config) {
    final idx = configuraciones.indexWhere((c) => c.idUsuario == config.idUsuario);
    if (idx != -1) {
      configuraciones[idx] = config;
    } else {
      configuraciones.add(config);
    }
    _save();
  }

  void saveSugerencia(Map<String, dynamic> sugerencia) {
    sugerencias.add(sugerencia);
    _save();
  }

  void clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _loaded = false;
    await init();
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
  int nextUsuarioId() => _nextId(usuarios, (u) => (u as Usuario).idUsuario);

  // Generador de IDs único para nuevos registros locales
  // Se usa microsegundos para minimizar riesgo de colisión en ráfagas.
  int generateId() => DateTime.now().microsecondsSinceEpoch;
}
