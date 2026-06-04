import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_l/features/auth/infrastructure/adapters/out/dtos/usuario_dto.dart';
import 'package:book_l/features/auth/domain/models/usuario.dart';
import 'package:book_l/features/curso/infrastructure/adapters/out/dtos/curso_dto.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/capitulo_dto.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/leccion_dto.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/dtos/material_dto.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/domain/models/material_educativo.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/out/dtos/configuracion_dto.dart';
import 'package:book_l/features/configuracion/domain/models/configuracion.dart';
import 'package:book_l/features/discusion/domain/models/discusion.dart';
import 'package:book_l/features/discusion/domain/models/comentario.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/out/dtos/discusion_dto.dart';
import 'package:book_l/features/ejercicio/infrastructure/adapters/out/dtos/ejercicio_dto.dart';
import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/domain/models/pregunta.dart';
import 'package:book_l/features/ejercicio/domain/models/opcion.dart';
import 'package:book_l/features/calificacion/infrastructure/adapters/out/dtos/calificacion_dto.dart';
import 'package:book_l/features/calificacion/domain/models/calificacion.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage.dart';
import 'supabase_client.dart';

// Servicio central de datos — Singleton global.
//
// REGLA DE USO: Solo los repository_impl pueden importar este servicio.
// Nunca importarlo directamente desde presentation/ ni desde domain/.
class BooklService extends ChangeNotifier {
  static const String _storageKey = 'bookl_full_data';
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BooklService _instance = BooklService._internal();
  factory BooklService() => _instance;
  BooklService._internal();

  void notifyDataChanged() {
    _save();
    notifyListeners();
  }

  // ── Estado ─────────────────────────────────────────────────────────────────
  bool _loaded = false;

  // ── "Tablas" en memoria ────────────────────────────────────────────────────
  String currentRole = 'user'; // 'user' o 'admin'

  void setRole(String role) {
    if (role.toLowerCase().contains('admin')) {
      currentRole = 'admin';
    } else {
      currentRole = 'user';
    }
    notifyListeners();
  }

  List<UsuarioDto> usuariosDto = []; // con contraseña — solo para auth
  List<Usuario> usuarios = []; // sin contraseña — exposición pública
  List<Curso> cursos = [];
  List<Leccion> lecciones = [];
  List<Capitulo> capitulos = [];
  List<MaterialEducativo> materiales = [];
  List<Configuracion> configuraciones = [];
  List<Map<String, dynamic>> sugerencias = [];
  List<Map<String, dynamic>> reportes = [];
  List<String> programas = [];

  // Pivote M:N lecciones ↔ cursos
  // Cada elemento es { 'id_leccion': int, 'id_curso': int }
  List<Map<String, int>> leccionesCursos = [];

  List<Map<String, dynamic>> seguidores = [];

  // Discusiones y comentarios
  List<Discusion> discusiones = [];
  List<Comentario> comentarios = [];

  // Ejercicios
  List<Ejercicio> ejercicios = [];
  List<Pregunta> preguntas = [];
  List<Opcion> opciones = [];

  // Calificaciones (Reseñas)
  List<Calificacion> calificaciones = [];

  // Progreso de usuario (por capítulo)
  List<Map<String, dynamic>> progresoUsuario = [];

  // Respuestas de usuario (historial de respuestas a preguntas)
  List<Map<String, dynamic>> respuestasUsuario = [];

  // Guardados (lecciones y cursos guardados por usuario)
  List<Map<String, dynamic>> guardados = [];
  List<Map<String, dynamic>> guardadosCursos = [];

  // Rachas (streak de actividad diaria por usuario)
  List<Map<String, dynamic>> rachas = [];

  // Notificaciones
  List<Map<String, dynamic>> notificaciones = [];

  // ── Inicialización (llamar una sola vez desde main.dart) ───────────────────
  Future<void> init() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();

    // Sincronizar el rol desde la sesión guardada si existe
    final savedRol = prefs.getString('rol');
    if (savedRol != null) {
      setRole(savedRol);
    }

    // 1. CARGA DE CACHÉ LOCAL (tolerancia a fallos inmediata)
    final localData = prefs.getString(_storageKey);
    Map<String, dynamic> data;
    try {
      if (localData != null && localData.isNotEmpty) {
        data = json.decode(localData);
      } else {
        final raw = await rootBundle.loadString('assets/data/bookl_data.json');
        data = json.decode(raw);
      }
    } catch (_) {
      final raw = await rootBundle.loadString('assets/data/bookl_data.json');
      data = json.decode(raw);
    }

    final rawStatic =
        await rootBundle.loadString('assets/data/bookl_data.json');
    final staticData = json.decode(rawStatic);
    programas = List<String>.from(staticData['programas'] ?? []);

    _populateFromMap(data);
    _loaded = true;
    notifyListeners();

    // 2. SINCRONIZACIÓN ASÍNCRONA EN SEGUNDO PLANO CON SUPABASE
    if (SupabaseClientHelper.isConfigured) {
      _syncFromSupabase();
    }
  }

  void _populateFromMap(Map<String, dynamic> data) {
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

    if (data.containsKey('seguidores')) {
      seguidores = List<Map<String, dynamic>>.from(data['seguidores']);
    } else {
      seguidores = [];
    }

    if (data.containsKey('discusiones')) {
      discusiones = (data['discusiones'] as List)
          .map((e) => DiscusionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      discusiones = [];
    }

    if (data.containsKey('comentarios')) {
      comentarios = (data['comentarios'] as List)
          .map((e) => ComentarioDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      comentarios = [];
    }

    if (data.containsKey('ejercicios')) {
      ejercicios = (data['ejercicios'] as List)
          .map<Ejercicio>(
              (e) => EjercicioDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      ejercicios = [];
    }

    if (data.containsKey('preguntas')) {
      preguntas = (data['preguntas'] as List)
          .map<Pregunta>((e) => PreguntaDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      preguntas = [];
    }

    if (data.containsKey('opciones')) {
      opciones = (data['opciones'] as List)
          .map<Opcion>((e) => OpcionDto.fromJson(e as Map<String, dynamic>))
          .toList();

      for (var p in preguntas) {
        final ops =
            opciones.where((o) => o.idPreguntaFk == p.idPregunta).toList();
        final i = preguntas.indexOf(p);
        preguntas[i] = Pregunta(
          idPregunta: p.idPregunta,
          idEjercicioFk: p.idEjercicioFk,
          contenido: p.contenido,
          explicacion: p.explicacion,
          opciones: ops,
        );
      }

      // Anidar preguntas en ejercicios
      for (var e in ejercicios) {
        final pregs =
            preguntas.where((p) => p.idEjercicioFk == e.idEjercicio).toList();
        final i = ejercicios.indexOf(e);
        ejercicios[i] = Ejercicio(
          idEjercicio: e.idEjercicio,
          idCapitulo: e.idCapitulo,
          tipo: e.tipo,
          titulo: e.titulo,
          descripcion: e.descripcion,
          preguntas: pregs,
        );
      }
    } else {
      opciones = [];
    }

    // ── Cargar Reportes con MERGE de Assets ─────────────────────────────────
    if (data.containsKey('reportes')) {
      reportes = List<Map<String, dynamic>>.from(data['reportes']);
    } else {
      reportes = [];
    }

    if (data.containsKey('calificaciones')) {
      calificaciones = (data['calificaciones'] as List)
          .map((e) => CalificacionDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      calificaciones = [];
    }

    if (data.containsKey('progreso_usuario')) {
      progresoUsuario =
          List<Map<String, dynamic>>.from(data['progreso_usuario']);
    } else {
      progresoUsuario = [];
    }
    if (data.containsKey('respuestas_usuario')) {
      respuestasUsuario =
          List<Map<String, dynamic>>.from(data['respuestas_usuario']);
    } else {
      respuestasUsuario = [];
    }
    if (data.containsKey('guardados')) {
      guardados = List<Map<String, dynamic>>.from(data['guardados']);
    } else {
      guardados = [];
    }
    if (data.containsKey('guardados_cursos')) {
      guardadosCursos =
          List<Map<String, dynamic>>.from(data['guardados_cursos']);
    } else {
      guardadosCursos = [];
    }
    if (data.containsKey('rachas')) {
      rachas = (data['rachas'] as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['dias_actividad'] = List<String>.from(map['dias_actividad'] ?? []);
        return map;
      }).toList();
    } else {
      rachas = [];
    }
    if (data.containsKey('notificaciones')) {
      notificaciones = List<Map<String, dynamic>>.from(data['notificaciones']);
    } else {
      notificaciones = [];
    }

    _nestRelations();
  }

  void _nestRelations() {
    for (var d in discusiones) {
      final coms =
          comentarios.where((c) => c.idDiscusionFk == d.idDiscusion).toList();
      final i = discusiones.indexOf(d);
      discusiones[i] = d.copyWith(comentarios: coms);
    }

    // Anidar discusiones en cursos
    for (var c in cursos) {
      final disc = discusiones.where((d) => d.idCursoFk == c.idCurso).toList();
      final i = cursos.indexOf(c);
      cursos[i] = c.copyWith(discusiones: disc);
    }

    // Anidar discusiones en lecciones
    for (var l in lecciones) {
      final disc =
          discusiones.where((d) => d.idLeccionFk == l.idLeccion).toList();
      final i = lecciones.indexOf(l);
      lecciones[i] = l.copyWith(discusiones: disc);
    }

    // Anidar ejercicios en capitulos
    for (var c in capitulos) {
      final ejs =
          ejercicios.where((e) => e.idCapitulo == c.idCapitulo).toList();
      final i = capitulos.indexOf(c);
      capitulos[i] = c.copyWith(ejercicios: ejs);
    }
  }

  Future<void> _syncFromSupabase() async {
    try {
      final client = SupabaseClientHelper.client;

      // Función auxiliar para atrapar errores por tabla
      Future<List<dynamic>> safeSelect(String table) async {
        try {
          return await client.from(table).select();
        } catch (e) {
          if (kDebugMode) print('Error fetching $table: $e');
          return [];
        }
      }

      int toInt(dynamic value, [int defaultValue = 0]) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? defaultValue;
        if (value is double) return value.toInt();
        return defaultValue;
      }

      int? toIntOrNull(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
        if (value is double) return value.toInt();
        return null;
      }

      // Carga en paralelo
      final results = await Future.wait([
        safeSelect('tbl_usuario'),
        safeSelect('tbl_curso'),
        safeSelect('tbl_leccion'),
        safeSelect('tbl_capitulo'),
        safeSelect('tbl_material'),
        safeSelect('tbl_configuracion'),
        safeSelect('tbl_lecciones_cursos'),
        safeSelect('tbl_seguidores'),
        safeSelect('tbl_discusion'),
        safeSelect('tbl_comentario'),
        safeSelect('tbl_ejercicio'),
        safeSelect('tbl_pregunta'),
        safeSelect('tbl_opcion'),
        safeSelect('tbl_reporte'),
        safeSelect('tbl_calificacion_leccion'),
        safeSelect('tbl_calificacion_curso'),
        safeSelect('tbl_progreso_usuario'),
        safeSelect('tbl_respuesta_usuario'),
        safeSelect('tbl_guardado_leccion'),
        safeSelect('tbl_guardado_curso'),
        safeSelect('tbl_racha'),
        safeSelect('tbl_notificacion'),
      ]);

      usuariosDto =
          (results[0] as List).map((e) => UsuarioDto.fromJson(e)).toList();
      usuarios = usuariosDto.map((d) => d.toEntity()).toList();

      cursos = (results[1] as List).map((e) => CursoDto.fromJson(e)).toList();
      lecciones =
          (results[2] as List).map((e) => LeccionDto.fromJson(e)).toList();
      capitulos =
          (results[3] as List).map((e) => CapituloDto.fromJson(e)).toList();
      materiales =
          (results[4] as List).map((e) => MaterialDto.fromJson(e)).toList();

      configuraciones = (results[5] as List)
          .map((e) => ConfiguracionDto.fromJson(e).toEntity())
          .toList();

      leccionesCursos = (results[6] as List)
          .map((e) => {
                'id_leccion': toInt(e['idleccion'] ?? e['id_leccion']),
                'id_curso': toInt(e['idcurso'] ?? e['id_curso']),
              })
          .toList();

      seguidores = List<Map<String, dynamic>>.from(results[7] as List);
      discusiones =
          (results[8] as List).map((e) => DiscusionDto.fromJson(e)).toList();
      comentarios =
          (results[9] as List).map((e) => ComentarioDto.fromJson(e)).toList();
      ejercicios =
          (results[10] as List).map((e) => EjercicioDto.fromJson(e)).toList();
      preguntas =
          (results[11] as List).map((e) => PreguntaDto.fromJson(e)).toList();
      opciones =
          (results[12] as List).map((e) => OpcionDto.fromJson(e)).toList();
      reportes = List<Map<String, dynamic>>.from(results[13] as List);

      final resCalL = results[14] as List;
      final resCalC = results[15] as List;
      calificaciones = [
        ...resCalL.map((e) => Calificacion(
              idCalificacion:
                  toInt(e['idcalificacion'] ?? e['id_calificacion']),
              idObjetoFk: toInt(e['idleccionfk'] ?? e['id_leccion_fk']),
              tipoObjeto: 'leccion',
              idUsuarioFk: toInt(e['idusuariofk'] ?? e['id_usuario_fk']),
              valor: toInt(e['valor']),
            )),
        ...resCalC.map((e) => Calificacion(
              idCalificacion:
                  toInt(e['idcalificacion'] ?? e['id_calificacion']),
              idObjetoFk: toInt(e['idcursofk'] ?? e['id_curso_fk']),
              tipoObjeto: 'curso',
              idUsuarioFk: toInt(e['idusuariofk'] ?? e['id_usuario_fk']),
              valor: toInt(e['valor']),
            )),
      ];

      progresoUsuario = List<Map<String, dynamic>>.from(results[16] as List);
      respuestasUsuario = List<Map<String, dynamic>>.from(results[17] as List);
      guardados = List<Map<String, dynamic>>.from(results[18] as List);
      guardadosCursos = List<Map<String, dynamic>>.from(results[19] as List);

      rachas = (results[20] as List)
          .map((e) => {
                'id_usuario': toInt(e['idusuario'] ?? e['id_usuario']),
                'racha_actual':
                    toInt(e['currentstreak'] ?? e['current_streak']),
                'dias_actividad': <String>[
                  if (e['lastactivitydate'] != null ||
                      e['last_activity_date'] != null)
                    (e['lastactivitydate'] ?? e['last_activity_date'])
                        .toString()
                        .split('T')[0]
                ],
              })
          .toList();

      notificaciones = (results[21] as List)
          .map((e) => {
                'id': toInt(e['idnotificacion'] ?? e['id_notificacion']),
                'id_usuario_fk':
                    toInt(e['idusuariofk'] ?? e['id_usuario_fk']),
                'tipo': e['tipo'] as String,
                'id_referencia':
                    toIntOrNull(e['idreferencia'] ?? e['id_referencia']),
                'mensaje': e['mensaje'] as String,
                'leida': e['leida'] as bool,
                'id_curso_fk': toIntOrNull(e['idcursofk'] ?? e['id_curso_fk']),
                'id_leccion_fk':
                    toIntOrNull(e['idleccionfk'] ?? e['id_leccion_fk']),
                'id_comentario_fk':
                    toIntOrNull(e['idcomentariofk'] ?? e['id_comentario_fk']),
                'created_at': e['created_at'] as String?,
              })
          .toList();

      for (var p in preguntas) {
        final ops =
            opciones.where((o) => o.idPreguntaFk == p.idPregunta).toList();
        final i = preguntas.indexOf(p);
        preguntas[i] = Pregunta(
          idPregunta: p.idPregunta,
          idEjercicioFk: p.idEjercicioFk,
          contenido: p.contenido,
          explicacion: p.explicacion,
          opciones: ops,
        );
      }

      for (var e in ejercicios) {
        final pregs =
            preguntas.where((p) => p.idEjercicioFk == e.idEjercicio).toList();
        final i = ejercicios.indexOf(e);
        ejercicios[i] = Ejercicio(
          idEjercicio: e.idEjercicio,
          idCapitulo: e.idCapitulo,
          tipo: e.tipo,
          titulo: e.titulo,
          descripcion: e.descripcion,
          preguntas: pregs,
        );
      }

      _nestRelations();
      seedAppSession();

      // Guardar a SharedPreferences local
      final prefs = await SharedPreferences.getInstance();
      final fullData = _toMap();
      await prefs.setString(_storageKey, json.encode(fullData));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing from Supabase: $e");
      }
    }
  }

  /// Carga la información del JSON en AppSession para que los datos
  /// de prueba iniciales sean visibles sin interacción previa del usuario.
  void seedAppSession() {
    final session = AppSession();
    final userId = session.usuarioId;
    if (userId == null) return; // No hay sesión activa, no sembramos

    // Completed Capitulos
    final completedCaps = progresoUsuario
        .where((p) {
          final uId = p['id_usuariofk'] ?? p['id_usuario_fk'] ?? p['idusuariofk'];
          return uId == userId && p['estado'] == 'completada';
        })
        .map<int>((p) => (p['id_capitulofk'] ?? p['id_capitulo_fk'] ?? p['idcapitulofk']) as int)
        .toSet();
    session.completedCapitulos.value = completedCaps;

    // Completed Ejercicios
    final userAnswers = respuestasUsuario.where((r) {
      final uId = r['idusuario'] ?? r['id_usuario'];
      return uId == userId;
    });
    final answeredPreguntaIds = userAnswers
        .map<int>((r) => (r['idpregunta'] ?? r['id_pregunta']) as int)
        .toSet();

    final completedEjs = <int>{};
    for (final ej in ejercicios) {
      if (ej.preguntas.isEmpty) continue;
      final allAnswered = ej.preguntas
          .every((p) => answeredPreguntaIds.contains(p.idPregunta));
      if (allAnswered) {
        completedEjs.add(ej.idEjercicio);
      }
    }
    session.completedEjercicios.value = completedEjs;

    // Saved Lecciones
    final savedLecs = guardados
        .where((g) {
          final uId = g['idusuario'] ?? g['id_usuario'];
          return uId == userId;
        })
        .map<int>((g) => (g['idleccion'] ?? g['id_leccion']) as int)
        .toSet();
    session.setSavedLecciones(savedLecs);

    // Saved Cursos
    final savedCurs = guardadosCursos
        .where((g) {
          final uId = g['idusuario'] ?? g['id_usuario'];
          return uId == userId;
        })
        .map<int>((g) => (g['idcurso'] ?? g['id_curso']) as int)
        .toSet();
    session.setSavedCursos(savedCurs);
  }

  Map<String, dynamic> _toMap() {
    return {
      'usuarios': usuariosDto.map((u) => u.toJson()).toList(),
      'cursos': cursos.map((c) => CursoDto.toJson(c)).toList(),
      'lecciones': lecciones.map((l) => LeccionDto.toJson(l)).toList(),
      'capitulos': capitulos.map((c) => CapituloDto.toJson(c)).toList(),
      'materiales': materiales.map((m) => MaterialDto.toJson(m)).toList(),
      'configuraciones': configuraciones
          .map((c) => ConfiguracionDto.fromEntity(c).toJson())
          .toList(),
      'sugerencias': sugerencias,
      'seguidores': seguidores,
      'discusiones': discusiones.map((d) => DiscusionDto.toJson(d)).toList(),
      'comentarios': comentarios.map((c) => ComentarioDto.toJson(c)).toList(),
      'ejercicios': ejercicios.map((e) => EjercicioDto.toJson(e)).toList(),
      'preguntas': preguntas.map((p) => PreguntaDto.toJson(p)).toList(),
      'opciones': opciones.map((o) => OpcionDto.toJson(o)).toList(),
      'reportes': reportes,
      'lecciones_cursos': leccionesCursos,
      'calificaciones':
          calificaciones.map((c) => CalificacionDto.toJson(c)).toList(),
      'progreso_usuario': progresoUsuario,
      'respuestas_usuario': respuestasUsuario,
      'guardados': guardados,
      'guardados_cursos': guardadosCursos,
      'rachas': rachas,
      'notificaciones': notificaciones,
    };
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullData = _toMap();
      await prefs.setString(_storageKey, json.encode(fullData));
    } catch (e) {
      if (kDebugMode) print("Error saving central data: $e");
    }
  }

  void guardarDatos() {
    _save();
    notifyListeners();
  }

  // ── Racha (Streak) ──────────────────────────────────────────────────────────
  Map<String, dynamic>? getRacha(int idUsuario) {
    try {
      return rachas.firstWhere((r) => r['id_usuario'] == idUsuario);
    } catch (_) {
      return null;
    }
  }

  void registrarActividad(int idUsuario) {
    if (idUsuario == 0) return;

    final hoy = DateTime.now();
    final hoyStr =
        '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    var rachaIdx = rachas.indexWhere((r) => r['id_usuario'] == idUsuario);
    int racha = 1;

    if (rachaIdx == -1) {
      rachas.add({
        'id_usuario': idUsuario,
        'dias_actividad': <String>[hoyStr],
        'racha_actual': 1,
      });
    } else {
      final dias = List<String>.from(rachas[rachaIdx]['dias_actividad'] ?? []);
      if (dias.contains(hoyStr)) return;

      dias.add(hoyStr);
      dias.sort();

      DateTime current = hoy;
      for (int i = dias.length - 2; i >= 0; i--) {
        final diaAnterior = DateTime.parse(dias[i]);
        final esperado = current.subtract(const Duration(days: 1));
        if (diaAnterior.year == esperado.year &&
            diaAnterior.month == esperado.month &&
            diaAnterior.day == esperado.day) {
          racha++;
          current = diaAnterior;
        } else {
          break;
        }
      }

      rachas[rachaIdx] = {
        'id_usuario': idUsuario,
        'dias_actividad': dias,
        'racha_actual': racha,
      };
    }

    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        client
            .from('tbl_racha')
            .upsert(
                Map<String, dynamic>.from(<String, dynamic>{
                  'id_usuario': idUsuario,
                  'current_streak': racha,
                  'max_streak': racha,
                  'last_activity_date': hoyStr,
                  'active': true,
                }),
                onConflict: 'id_usuario')
            .then((_) => null,
                onError: (e) => debugPrint("Supabase racha error: $e"));
      } catch (e) {
        debugPrint("Error syncing racha: $e");
      }
    }
  }

  // ── Operaciones de Escritura ───────────────────────────────────────────────
  void updateUsuario(Usuario usuario) {
    final idx = usuarios.indexWhere((u) => u.idUsuario == usuario.idUsuario);
    if (idx != -1) {
      usuarios[idx] = usuario;

      final dtoIdx =
          usuariosDto.indexWhere((u) => u.idUsuario == usuario.idUsuario);
      if (dtoIdx != -1) {
        usuariosDto[dtoIdx] = UsuarioDto(
          idUsuario: usuario.idUsuario,
          nombreCompleto: usuario.nombreCompleto,
          correo: usuario.correo,
          contrasena: usuariosDto[dtoIdx].contrasena,
          rol: usuario.rol,
          programa: usuario.programa,
          activo: usuario.activo,
          avatarUrl: usuario.avatarUrl,
          username: usuario.username,
          descripcion: usuario.descripcion,
          celular: usuario.celular,
          semestre: usuario.semestre,
          nacimiento: usuario.nacimiento,
          preferencias: usuario.preferencias,
        );
      }
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          final userMap = <String, dynamic>{
            'nombrecompleto': usuario.nombreCompleto,
            'correo': usuario.correo,
            'rol': usuario.rol,
            'programa': usuario.programa,
            'activo': usuario.activo,
            'avatar_url': usuario.avatarUrl,
            'username': usuario.username,
            'descripcion': usuario.descripcion,
            'celular': usuario.celular,
            'semestre': usuario.semestre,
            if (usuario.nacimiento != null)
              'nacimiento': usuario.nacimiento!.toIso8601String().split('T')[0],
            if (usuario.preferencias != null)
              'preferencias': usuario.preferencias,
          }..removeWhere((_, v) => v == null);
          SupabaseClientHelper.client
              .from('tbl_usuario')
              .update(Map<String, dynamic>.from(userMap))
              .eq('idusuario', usuario.idUsuario)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (e) {
          debugPrint("Error updating usuario: $e");
        }
      }
    }
  }

  void addCurso(Curso curso, {bool syncToSupabase = true}) {
    cursos.add(curso);
    registrarActividad(AppSession().usuarioId ?? 0);
    _save();
    notifyListeners();

    if (syncToSupabase && SupabaseClientHelper.isConfigured) {
      try {
        final cursoMap = <String, dynamic>{
          'idcurso': curso.idCurso,
          'idusuariofk': curso.idUsuarioFk,
          'nombre': curso.nombre,
          'esnuevo': curso.esNuevo ?? true,
          'estado': curso.estado ?? 'activo',
        };
        if (curso.imagenUrl != null) cursoMap['imagen_url'] = curso.imagenUrl!;
        if (curso.tagColor != null) cursoMap['tagcolor'] = curso.tagColor!;
        if (curso.duracion != null && curso.duracion!.isNotEmpty)
          cursoMap['duracion'] = curso.duracion!;
        if (curso.contenido != null)
          cursoMap['contenido'] = jsonEncode(curso.contenido);
        SupabaseClientHelper.client
            .from('tbl_curso')
            .insert(Map<String, dynamic>.from(cursoMap))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error adding curso: $e");
      }
    }
  }

  void addLeccion(Leccion leccion, {int? idCurso, bool syncToSupabase = true}) {
    lecciones.add(leccion);
    if (idCurso != null) {
      leccionesCursos.add({
        'id_leccion': leccion.idLeccion,
        'id_curso': idCurso,
      });
    }
    registrarActividad(AppSession().usuarioId ?? 0);
    _save();
    notifyListeners();

    if (syncToSupabase && SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        final leccionMap = <String, dynamic>{
          'idleccion': leccion.idLeccion,
          'idusuariofk': leccion.idUsuarioFk,
          'nombre': leccion.nombre,
          'esnuevo': leccion.esNuevo ?? true,
          'estado': leccion.estado ?? 'activa',
        };
        if (leccion.imagenUrl != null)
          leccionMap['imagen_url'] = leccion.imagenUrl!;
        if (leccion.tagColor != null)
          leccionMap['tagcolor'] = leccion.tagColor!;
        if (leccion.duracion != null && leccion.duracion!.isNotEmpty)
          leccionMap['duracion'] = leccion.duracion!;
        if (leccion.contenido != null)
          leccionMap['contenido'] = jsonEncode(leccion.contenido);
        client
            .from('tbl_leccion')
            .insert(Map<String, dynamic>.from(leccionMap))
            .then((_) {
          if (idCurso != null) {
            client
                .from('tbl_lecciones_cursos')
                .insert(Map<String, dynamic>.from(<String, dynamic>{
                  'idleccion': leccion.idLeccion,
                  'idcurso': idCurso,
                }))
                .then((_) => null,
                    onError: (e) => debugPrint("Supabase error: $e"));
          }
        }, onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error adding leccion: $e");
      }
    }
  }

  void updateLeccion(Leccion leccion) {
    final idx = lecciones.indexWhere((l) => l.idLeccion == leccion.idLeccion);
    if (idx != -1) {
      lecciones[idx] = leccion;
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          final updateMap = <String, dynamic>{
            'nombre': leccion.nombre,
            'esnuevo': leccion.esNuevo ?? true,
            'estado': leccion.estado ?? 'activa',
          };
          if (leccion.imagenUrl != null)
            updateMap['imagen_url'] = leccion.imagenUrl!;
          if (leccion.tagColor != null)
            updateMap['tagcolor'] = leccion.tagColor!;
          if (leccion.duracion != null && leccion.duracion!.isNotEmpty)
            updateMap['duracion'] = leccion.duracion!;
          if (leccion.contenido != null)
            updateMap['contenido'] = jsonEncode(leccion.contenido);
          SupabaseClientHelper.client
              .from('tbl_leccion')
              .update(Map<String, dynamic>.from(updateMap))
              .eq('idleccion', leccion.idLeccion)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (e) {
          debugPrint("Error updating leccion: $e");
        }
      }
    }
  }

  void addCapitulo(Capitulo capitulo, {bool syncToSupabase = true}) {
    capitulos.add(capitulo);
    _save();
    notifyListeners();

    if (syncToSupabase && SupabaseClientHelper.isConfigured) {
      try {
        final capMap = <String, dynamic>{
          'idcapitulo': capitulo.idCapitulo,
          'idleccion': capitulo.idLeccion,
          'nombre': capitulo.nombre,
          'tiempo_total': capitulo.tiempoTotal,
          if (capitulo.contenido != null)
            'contenido': jsonEncode(capitulo.contenido),
        }..removeWhere((_, v) => v == null);
        SupabaseClientHelper.client
            .from('tbl_capitulo')
            .insert(Map<String, dynamic>.from(capMap))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error adding capitulo: $e");
      }
    }
  }

  void updateCapitulo(Capitulo capitulo) {
    final idx =
        capitulos.indexWhere((c) => c.idCapitulo == capitulo.idCapitulo);
    if (idx != -1) {
      capitulos[idx] = capitulo;
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          final capUpdateMap = <String, dynamic>{
            'idleccion': capitulo.idLeccion,
            'nombre': capitulo.nombre,
            'tiempo_total': capitulo.tiempoTotal,
            if (capitulo.contenido != null)
              'contenido': jsonEncode(capitulo.contenido),
          }..removeWhere((_, v) => v == null);
          SupabaseClientHelper.client
              .from('tbl_capitulo')
              .update(Map<String, dynamic>.from(capUpdateMap))
              .eq('idcapitulo', capitulo.idCapitulo)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (e) {
          debugPrint("Error updating capitulo: $e");
        }
      }
    }
  }

  void updateCurso(Curso curso) {
    final idx = cursos.indexWhere((c) => c.idCurso == curso.idCurso);
    if (idx != -1) {
      cursos[idx] = curso;
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          final updateCursoMap = <String, dynamic>{
            'nombre': curso.nombre,
            'esnuevo': curso.esNuevo ?? true,
            'estado': curso.estado ?? 'activo',
          };
          if (curso.imagenUrl != null)
            updateCursoMap['imagen_url'] = curso.imagenUrl!;
          if (curso.tagColor != null)
            updateCursoMap['tagcolor'] = curso.tagColor!;
          if (curso.duracion != null && curso.duracion!.isNotEmpty)
            updateCursoMap['duracion'] = curso.duracion!;
          if (curso.contenido != null)
            updateCursoMap['contenido'] = jsonEncode(curso.contenido);
          SupabaseClientHelper.client
              .from('tbl_curso')
              .update(Map<String, dynamic>.from(updateCursoMap))
              .eq('idcurso', curso.idCurso)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (e) {
          debugPrint("Error updating curso: $e");
        }
      }
    }
  }

  void removeCurso(int id) {
    cursos.removeWhere((c) => c.idCurso == id);
    leccionesCursos.removeWhere((lc) => lc['id_curso'] == id);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_curso')
            .delete()
            .eq('idcurso', id)
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error removing curso: $e");
      }
    }
  }

  void asociarLeccion(int idCurso, int idLeccion) {
    final yaExiste = leccionesCursos.any(
      (e) => e['id_curso'] == idCurso && e['id_leccion'] == idLeccion,
    );
    if (!yaExiste) {
      leccionesCursos.add({'id_curso': idCurso, 'id_leccion': idLeccion});
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          SupabaseClientHelper.client
              .from('tbl_lecciones_cursos')
              .insert(Map<String, dynamic>.from(<String, dynamic>{
                'idcurso': idCurso,
                'idleccion': idLeccion,
              }))
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (e) {
          debugPrint("Error adding lecciones_cursos: $e");
        }
      }
    }
  }

  void save() {
    _save();
  }

  void desasociarLeccion(int idCurso, int idLeccion) {
    leccionesCursos.removeWhere(
      (e) => e['id_curso'] == idCurso && e['id_leccion'] == idLeccion,
    );
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_lecciones_cursos')
            .delete()
            .eq('idcurso', idCurso)
            .eq('idleccion', idLeccion)
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error removing lecciones_cursos: $e");
      }
    }
  }

  void removeLeccion(int id) {
    lecciones.removeWhere((l) => l.idLeccion == id);
    leccionesCursos.removeWhere((lc) => lc['id_leccion'] == id);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_leccion')
            .delete()
            .eq('idleccion', id)
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error removing leccion: $e");
      }
    }
  }

  void removeCapitulo(int id) {
    capitulos.removeWhere((c) => c.idCapitulo == id);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_capitulo')
            .delete()
            .eq('idcapitulo', id)
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error removing capitulo: $e");
      }
    }
  }

  void saveConfiguracion(Configuracion config) {
    final idx =
        configuraciones.indexWhere((c) => c.idUsuario == config.idUsuario);
    if (idx != -1) {
      configuraciones[idx] = config;
    } else {
      configuraciones.add(config);
    }
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_configuracion')
            .upsert(
                Map<String, dynamic>.from(<String, dynamic>{
                  'idusuario': config.idUsuario,
                  'tema': config.temaOscuro,
                  'idioma': config.idioma,
                  'notificaciones_push': config.notificacionesPush,
                  'notificaciones_email': config.notificacionesEmail,
                  'notificaciones_racha': config.notificacionesRacha,
                  'tamano_fuente': config.tamanoFuente,
                  'reproduccion_auto': config.reproduccionAuto,
                  'perfil_publico': config.perfilPublico,
                }),
                onConflict: 'idusuario')
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error saving configuracion: $e");
      }
    }
  }

  void saveSugerencia(Map<String, dynamic> sugerencia) {
    sugerencias.add(sugerencia);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_reporte')
            .insert(Map<String, dynamic>.from(<String, dynamic>{
              'idusuariofk': sugerencia['id_usuario'] as Object,
              'entidad_tipo': 'sugerencia',
              'entidad_id': sugerencia['id_sugerencia'] ?? 0,
              'motivo':
                  'Asunto: ${sugerencia['asunto']}\nProblema: ${sugerencia['problema']}',
            }))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (e) {
        debugPrint("Error saving sugerencia: $e");
      }
    }
  }

  // ── Operaciones Ejercicios ─────────────────────────────────────────────────
  void addEjercicio(Ejercicio e) {
    ejercicios.add(e);
    final capIdx = capitulos.indexWhere((c) => c.idCapitulo == e.idCapitulo);
    if (capIdx != -1) {
      final cap = capitulos[capIdx];
      capitulos[capIdx] = cap.copyWith(
        ejercicios: [...cap.ejercicios, e],
      );
    }
    _save();
    notifyListeners();
  }

  void updateEjercicio(Ejercicio e) {
    final idx = ejercicios.indexWhere((x) => x.idEjercicio == e.idEjercicio);
    if (idx != -1) {
      ejercicios[idx] = e;
      final capIdx = capitulos.indexWhere((c) => c.idCapitulo == e.idCapitulo);
      if (capIdx != -1) {
        final cap = capitulos[capIdx];
        final updatedEjs = cap.ejercicios
            .map(
              (x) => x.idEjercicio == e.idEjercicio ? e : x,
            )
            .toList();
        capitulos[capIdx] = cap.copyWith(ejercicios: updatedEjs);
      }
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          SupabaseClientHelper.client
              .from('tbl_ejercicio')
              .update(Map<String, dynamic>.from({
                'tipo': e.tipo.name,
                'titulo': e.titulo,
                'descripcion': e.descripcion,
              }))
              .eq('idejercicio', e.idEjercicio)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (ex) {
          debugPrint("Error updating ejercicio: $ex");
        }
      }
    }
  }

  void removeEjercicio(int idEjercicio) {
    final ej = ejercicios.firstWhere(
      (e) => e.idEjercicio == idEjercicio,
      orElse: () => const Ejercicio(
          idEjercicio: -1,
          idCapitulo: -1,
          tipo: TipoEjercicio.multipleChoice,
          titulo: '',
          descripcion: ''),
    );
    ejercicios.removeWhere((e) => e.idEjercicio == idEjercicio);
    final pregIds = preguntas
        .where((p) => p.idEjercicioFk == idEjercicio)
        .map((p) => p.idPregunta)
        .toSet();
    opciones.removeWhere((o) => pregIds.contains(o.idPreguntaFk));
    preguntas.removeWhere((p) => p.idEjercicioFk == idEjercicio);
    if (ej.idCapitulo != -1) {
      final capIdx = capitulos.indexWhere((c) => c.idCapitulo == ej.idCapitulo);
      if (capIdx != -1) {
        final cap = capitulos[capIdx];
        capitulos[capIdx] = cap.copyWith(
          ejercicios: cap.ejercicios
              .where((e) => e.idEjercicio != idEjercicio)
              .toList(),
        );
      }
    }
    _save();
    notifyListeners();
  }

  void addPregunta(Pregunta p) {
    preguntas.add(p);
    final ejIdx =
        ejercicios.indexWhere((e) => e.idEjercicio == p.idEjercicioFk);
    if (ejIdx != -1) {
      final ej = ejercicios[ejIdx];
      ejercicios[ejIdx] = Ejercicio(
        idEjercicio: ej.idEjercicio,
        idCapitulo: ej.idCapitulo,
        tipo: ej.tipo,
        titulo: ej.titulo,
        descripcion: ej.descripcion,
        preguntas: [...ej.preguntas, p],
      );
    }
    _save();
    notifyListeners();
  }

  void addOpcion(Opcion o) {
    opciones.add(o);
    final pIdx = preguntas.indexWhere((p) => p.idPregunta == o.idPreguntaFk);
    if (pIdx != -1) {
      final pr = preguntas[pIdx];
      preguntas[pIdx] = Pregunta(
        idPregunta: pr.idPregunta,
        idEjercicioFk: pr.idEjercicioFk,
        contenido: pr.contenido,
        explicacion: pr.explicacion,
        opciones: [...pr.opciones, o],
      );
    }
    _save();
    notifyListeners();
  }

  // ── Operaciones Discusión ─────────────────────────────────────────────────
  void addDiscusion(Discusion d, {bool syncToSupabase = true}) {
    discusiones.add(d);
    _save();
    notifyListeners();

    if (syncToSupabase && SupabaseClientHelper.isConfigured) {
      try {
        final discMap = <String, dynamic>{
          'id_discusion': d.idDiscusion,
          'id_cursofk': d.idCursoFk,
          'id_leccionfk': d.idLeccionFk,
        }..removeWhere((_, v) => v == null);
        SupabaseClientHelper.client
            .from('tbl_discusion')
            .insert(Map<String, dynamic>.from(discMap))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (ex) {
        debugPrint("Error adding discusion: $ex");
      }
    }
  }

  void addComentario(Comentario c, {bool syncToSupabase = true}) {
    // Deduplicar: no agregar si ya existe un comentario con el mismo ID
    if (comentarios.any((lc) => lc.idComentario == c.idComentario)) {
      return;
    }
    comentarios.add(c);
    _save();
    notifyListeners();

    if (syncToSupabase && SupabaseClientHelper.isConfigured) {
      try {
        final comMap = <String, dynamic>{
          'id_comentario': c.idComentario,
          'id_discusionfk': c.idDiscusionFk,
          'id_usuariofk': c.idUsuarioFk,
          'contenido': c.contenido,
          'id_padre': c.idPadre,
        }..removeWhere((_, v) => v == null);
        SupabaseClientHelper.client
            .from('tbl_comentario')
            .insert(Map<String, dynamic>.from(comMap))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (ex) {
        debugPrint("Error adding comentario: $ex");
      }
    }
  }

  int getComentariosCount(int idDiscusion) {
    return comentarios.where((c) => c.idDiscusionFk == idDiscusion).length;
  }

  bool isFollowing(int idSeguidor, int idSeguido) {
    return seguidores.any((s) =>
        s['id_seguidor'] == idSeguidor &&
        s['id_seguido'] == idSeguido &&
        s['estado'] == 'activo');
  }

  void toggleSeguir(int idSeguidor, int idSeguido) {
    final idx = seguidores.indexWhere(
        (s) => s['id_seguidor'] == idSeguidor && s['id_seguido'] == idSeguido);

    bool isNewFollow = false;
    String estadoFinal = 'activo';

    if (idx != -1) {
      if (seguidores[idx]['estado'] == 'activo') {
        seguidores[idx]['estado'] = 'bloqueado';
        estadoFinal = 'bloqueado';
      } else {
        seguidores[idx]['estado'] = 'activo';
        isNewFollow = true;
      }
    } else {
      seguidores.add({
        'id_seguidor': idSeguidor,
        'id_seguido': idSeguido,
        'estado': 'activo',
        'created_at': DateTime.now().toIso8601String(),
      });
      isNewFollow = true;
    }

    if (isNewFollow) {
      String nombreSeguidor = 'Un usuario';
      final u = usuarios.where((u) => u.idUsuario == idSeguidor).firstOrNull;
      if (u != null) {
        nombreSeguidor = u.nombreCompleto;
      }

      final notifId = generateId();
      notificaciones.insert(0, {
        'id': notifId,
        'id_usuario_fk': idSeguido,
        'tipo': 'follow',
        'id_referencia': idSeguidor,
        'mensaje': '$nombreSeguidor ha comenzado a seguirte.',
        'leida': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (SupabaseClientHelper.isConfigured) {
        try {
          SupabaseClientHelper.client.from('tbl_notificacion').insert({
            'idusuariofk': idSeguido,
            'tipo': 'follow',
            'idreferencia': idSeguidor,
            'mensaje': '$nombreSeguidor ha comenzado a seguirte.',
            'leida': false,
          }).then((_) => null,
              onError: (e) => debugPrint("Supabase notif error: $e"));
        } catch (e) {
          debugPrint("Error syncing follow notification: $e");
        }
      }
    }

    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        if (idx != -1) {
          client
              .from('tbl_seguidores')
              .update(Map<String, dynamic>.from({
                'estado': estadoFinal,
              }))
              .eq('idseguidor', idSeguidor)
              .eq('idseguido', idSeguido)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } else {
          client
              .from('tbl_seguidores')
              .insert(Map<String, dynamic>.from(<String, dynamic>{
                'idseguidor': idSeguidor,
                'idseguido': idSeguido,
                'estado': 'activo',
              }))
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        }
      } catch (ex) {
        debugPrint("Error syncing followers: $ex");
      }
    }
  }

  int getFollowersCount(int idUsuario) {
    return seguidores
        .where((s) => s['id_seguido'] == idUsuario && s['estado'] == 'activo')
        .length;
  }

  int getFollowingCount(int idUsuario) {
    return seguidores
        .where((s) => s['id_seguidor'] == idUsuario && s['estado'] == 'activo')
        .length;
  }

  // ── Notificaciones ────────────────────────────────────────────────────────

  void generarNotificacion({
    required int idUsuarioDestino,
    required String tipo,
    required String mensaje,
    int? idReferencia,
    int? idCursoFk,
    int? idLeccionFk,
    int? idComentarioFk,
  }) {
    final notifId = generateId();
    final notifMap = {
      'id': notifId,
      'id_usuario_fk': idUsuarioDestino,
      'tipo': tipo,
      'mensaje': mensaje,
      'id_referencia': idReferencia,
      'id_curso_fk': idCursoFk,
      'id_leccion_fk': idLeccionFk,
      'id_comentario_fk': idComentarioFk,
      'leida': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    notificaciones.insert(0, notifMap);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client.from('tbl_notificacion').insert({
          'idusuariofk': idUsuarioDestino,
          'tipo': tipo,
          'mensaje': mensaje,
          if (idReferencia != null) 'idreferencia': idReferencia,
          if (idCursoFk != null) 'idcursofk': idCursoFk,
          if (idLeccionFk != null) 'idleccionfk': idLeccionFk,
          if (idComentarioFk != null) 'idcomentariofk': idComentarioFk,
          'leida': false,
        }).then((_) => null,
            onError: (e) => debugPrint("Supabase notif error: $e"));
      } catch (e) {
        debugPrint("Error syncing notification: $e");
      }
    }
  }

  void marcarNotificacionesComoLeidas(int idUsuario) {
    bool changed = false;
    for (var n in notificaciones) {
      if (n['id_usuario_fk'] == idUsuario && n['leida'] == false) {
        n['leida'] = true;
        changed = true;
      }
    }
    if (changed) {
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          SupabaseClientHelper.client
              .from('tbl_notificacion')
              .update(Map<String, dynamic>.from({'leida': true}))
              .eq('idusuariofk', idUsuario)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (ex) {
          debugPrint("Error syncing notificaciones: $ex");
        }
      }
    }
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
  int nextCapituloId() => _nextId(capitulos, (c) => (c as Capitulo).idCapitulo);
  int nextUsuarioId() => _nextId(usuarios, (u) => (u as Usuario).idUsuario);
  int nextMaterialId() =>
      _nextId(materiales, (m) => (m as MaterialEducativo).idMaterial);
  int nextEjercicioId() =>
      _nextId(ejercicios, (e) => (e as Ejercicio).idEjercicio);
  int nextPreguntaId() => _nextId(preguntas, (p) => (p as Pregunta).idPregunta);
  int nextOpcionId() => _nextId(opciones, (o) => (o as Opcion).idOpcion);

  int nextReporteId() {
    if (reportes.isEmpty) return 1;
    return reportes
            .map<int>((r) => (r['id_reporte'] as int?) ?? 0)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  int generateId() => DateTime.now().microsecondsSinceEpoch;

  // ── Operaciones de Reportes ────────────────────────────────────────────────
  void addReporte({
    required int idUsuarioFk,
    required String entidadTipo,
    required int entidadId,
    required String motivo,
  }) {
    final repId = nextReporteId();
    final nuevoReporte = {
      'id_reporte': repId,
      'id_usuario_fk': idUsuarioFk,
      'entidad_tipo': entidadTipo,
      'entidad_id': entidadId,
      'motivo': motivo,
      'created_at': DateTime.now().toIso8601String(),
    };
    reportes.add(nuevoReporte);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_reporte')
            .insert(Map<String, dynamic>.from(<String, dynamic>{
              'idreporte': repId,
              'idusuariofk': idUsuarioFk,
              'entidad_tipo': entidadTipo,
              'entidad_id': entidadId,
              'motivo': motivo,
            }))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (ex) {
        debugPrint("Error adding reporte: $ex");
      }
    }
  }

  // ── Operaciones Material Educativo ──────────────────────────────────────────
  void addMaterial(MaterialEducativo m) {
    materiales.add(m);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        final matMap = <String, dynamic>{
          'idmaterial': m.idMaterial,
          'idleccionfk': m.idLeccionFk,
          'nombre': m.nombre,
          'url': m.url,
          'descripcion': m.descripcion,
          'tipo': m.tipo,
          'tamano_bytes': m.tamanoBytes,
        }..removeWhere((_, v) => v == null);
        SupabaseClientHelper.client
            .from('tbl_material')
            .insert(Map<String, dynamic>.from(matMap))
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (ex) {
        debugPrint("Error adding material: $ex");
      }
    }
  }

  void updateMaterial(MaterialEducativo m) {
    final idx = materiales.indexWhere((x) => x.idMaterial == m.idMaterial);
    if (idx != -1) {
      materiales[idx] = m;
      _save();
      notifyListeners();

      if (SupabaseClientHelper.isConfigured) {
        try {
          final matUpdateMap = <String, dynamic>{
            'nombre': m.nombre,
            'url': m.url,
            'descripcion': m.descripcion,
            'tipo': m.tipo,
            'tamano_bytes': m.tamanoBytes,
          }..removeWhere((_, v) => v == null);
          SupabaseClientHelper.client
              .from('tbl_material')
              .update(Map<String, dynamic>.from(matUpdateMap))
              .eq('idmaterial', m.idMaterial)
              .then((_) => null,
                  onError: (e) => debugPrint("Supabase error: $e"));
        } catch (ex) {
          debugPrint("Error updating material: $ex");
        }
      }
    }
  }

  void removeMaterial(int id) {
    materiales.removeWhere((m) => m.idMaterial == id);
    _save();
    notifyListeners();

    if (SupabaseClientHelper.isConfigured) {
      try {
        SupabaseClientHelper.client
            .from('tbl_material')
            .delete()
            .eq('idmaterial', id)
            .then((_) => null,
                onError: (e) => debugPrint("Supabase error: $e"));
      } catch (ex) {
        debugPrint("Error removing material: $ex");
      }
    }
  }

  List<MaterialEducativo> materialesDeLeccion(int idLeccion) {
    return materiales.where((m) => m.idLeccionFk == idLeccion).toList();
  }

  // ── Calificaciones (Reseñas Dinámicas) ─────────────────────────────────────
  Future<(double, bool)> agregarOActualizarCalificacion(
      int idObjeto, String tipoObjeto, int idUsuario, int valor) async {
    bool isUpdate = false;
    final index = calificaciones.indexWhere((c) =>
        c.idObjetoFk == idObjeto &&
        c.tipoObjeto == tipoObjeto &&
        c.idUsuarioFk == idUsuario);

    if (index >= 0) {
      calificaciones[index] = calificaciones[index].copyWith(valor: valor);
      isUpdate = true;
    } else {
      final newId = calificaciones.isEmpty
          ? 1
          : calificaciones
                  .map((c) => c.idCalificacion)
                  .reduce((a, b) => a > b ? a : b) +
              1;
      calificaciones.add(Calificacion(
        idCalificacion: newId,
        idObjetoFk: idObjeto,
        tipoObjeto: tipoObjeto,
        idUsuarioFk: idUsuario,
        valor: valor,
      ));
    }

    final calificacionesDelObjeto = calificaciones
        .where((c) => c.idObjetoFk == idObjeto && c.tipoObjeto == tipoObjeto)
        .toList();

    double nuevoPromedio = 0.0;
    if (calificacionesDelObjeto.isNotEmpty) {
      final suma =
          calificacionesDelObjeto.fold<int>(0, (sum, c) => sum + c.valor);
      nuevoPromedio = suma / calificacionesDelObjeto.length;
    }

    if (tipoObjeto == 'leccion') {
      final iLeccion = lecciones.indexWhere((l) => l.idLeccion == idObjeto);
      if (iLeccion >= 0) {
        lecciones[iLeccion] = lecciones[iLeccion]
            .copyWith(rating: double.parse(nuevoPromedio.toStringAsFixed(1)));
        nuevoPromedio = lecciones[iLeccion].rating;
        // Nota: tbl_leccion no tiene columna 'rating' en Supabase.
        // El rating se calcula desde tbl_calificacion_leccion.
      }
    } else if (tipoObjeto == 'curso') {
      final iCurso = cursos.indexWhere((c) => c.idCurso == idObjeto);
      if (iCurso >= 0) {
        cursos[iCurso] = cursos[iCurso]
            .copyWith(rating: double.parse(nuevoPromedio.toStringAsFixed(1)));
        nuevoPromedio = cursos[iCurso].rating;
        // Nota: tbl_curso no tiene columna 'rating' en Supabase.
        // El rating se calcula desde tbl_calificacion_curso.
      }
    }

    await _save();
    notifyListeners();

    return (nuevoPromedio, isUpdate);
  }
}
