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
import '../../features/discusion/domain/entities/discusion.dart';
import '../../features/discusion/domain/entities/comentario.dart';
import '../../features/discusion/data/dto/discusion_dto.dart';
import '../../features/ejercicio/data/dto/ejercicio_dto.dart';
import '../../features/ejercicio/domain/entities/ejercicio.dart';
import '../../features/ejercicio/domain/entities/pregunta.dart';
import '../../features/ejercicio/domain/entities/opcion.dart';
import '../../features/calificacion/data/dto/calificacion_dto.dart';
import '../../features/calificacion/domain/entities/calificacion.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../storage/local_storage.dart';

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
  List<Usuario> usuarios = [];       // sin contraseña — exposición pública
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

    final localData = prefs.getString(_storageKey);

    Map<String, dynamic> data;
    if (localData != null && localData.isNotEmpty) {
      data = json.decode(localData);
    } else {
      final raw = await rootBundle.loadString('assets/data/bookl_data.json');
      data = json.decode(raw);
    }

    // Cargar datos estáticos directamente del JSON (no se persisten simuladamente)
    final rawStatic = await rootBundle.loadString('assets/data/bookl_data.json');
    final staticData = json.decode(rawStatic);
    programas = List<String>.from(staticData['programas'] ?? []);

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
          .map<Ejercicio>((e) => EjercicioDto.fromJson(e as Map<String, dynamic>))
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
      
      // Anidar opciones en preguntas
      for (var p in preguntas) {
        final ops = opciones.where((o) => o.idPreguntaFk == p.idPregunta).toList();
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
        final pregs = preguntas.where((p) => p.idEjercicioFk == e.idEjercicio).toList();
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

    // Leemos siempre del asset para ver si hay reportes nuevos agregados manualmente
    try {
      final rawAsset = await rootBundle.loadString('assets/data/bookl_data.json');
      final assetData = json.decode(rawAsset);
      if (assetData.containsKey('reportes')) {
        final assetReportes = List<Map<String, dynamic>>.from(assetData['reportes']);
        for (var ar in assetReportes) {
          // Si el ID de reporte no está en memoria, lo agregamos
          if (!reportes.any((r) => r['id_reporte'] == ar['id_reporte'])) {
            reportes.add(ar);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error merging reportes from asset: $e");
    }

    // ── Anidación Relacional Final ──────────────────────────────────────────
    // Anidar comentarios en discusiones
    for (var d in discusiones) {
      final coms = comentarios.where((c) => c.idDiscusionFk == d.idDiscusion).toList();
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
      final disc = discusiones.where((d) => d.idLeccionFk == l.idLeccion).toList();
      final i = lecciones.indexOf(l);
      lecciones[i] = l.copyWith(discusiones: disc);
    }

    // Anidar ejercicios en capitulos
    for (var c in capitulos) {
      final ejs = ejercicios.where((e) => e.idCapitulo == c.idCapitulo).toList();
      final i = capitulos.indexOf(c);
      capitulos[i] = c.copyWith(ejercicios: ejs);
    }

    // ── Cargar Progreso, Respuestas, Guardados ─────────────────────────────
    if (data.containsKey('progreso_usuario')) {
      progresoUsuario = List<Map<String, dynamic>>.from(data['progreso_usuario']);
    }
    if (data.containsKey('respuestas_usuario')) {
      respuestasUsuario = List<Map<String, dynamic>>.from(data['respuestas_usuario']);
    }
    if (data.containsKey('guardados')) {
      guardados = List<Map<String, dynamic>>.from(data['guardados']);
    }
    if (data.containsKey('guardados_cursos')) {
      guardadosCursos = List<Map<String, dynamic>>.from(data['guardados_cursos']);
    }
    if (data.containsKey('rachas')) {
      rachas = (data['rachas'] as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        // Asegurar que dias_actividad sea List<String>
        map['dias_actividad'] = List<String>.from(map['dias_actividad'] ?? []);
        return map;
      }).toList();
    }
    if (data.containsKey('notificaciones')) {
      notificaciones = List<Map<String, dynamic>>.from(data['notificaciones']);
    }

    // ── Semilla: cargar progreso inicial en AppSession ─────────────────────
    _seedAppSession();

    _loaded = true;
    notifyListeners();
  }

  /// Carga la información del JSON en AppSession para que los datos
  /// de prueba iniciales sean visibles sin interacción previa del usuario.
  void _seedAppSession() {
    final session = AppSession();
    // Solo sembramos si AppSession ya fue inicializado y no tiene data previa
    // (es decir, la primera vez que se carga). Si ya existe data en SharedPrefs
    // AppSession ya la habrá cargado en su propio init().

    final userId = session.usuarioId;
    if (userId == null) return; // No hay sesión activa, no sembramos

    // ── Semilla: Capítulos completados ────────────────────────────────────
    if (session.completedCapitulos.value.isEmpty) {
      final completedCaps = progresoUsuario
          .where((p) => p['id_usuario_fk'] == userId && p['estado'] == 'completada')
          .map<int>((p) => p['id_capitulo_fk'] as int)
          .toSet();
      if (completedCaps.isNotEmpty) {
        session.completedCapitulos.value = completedCaps;
      }
    }

    // ── Semilla: Ejercicios completados ───────────────────────────────────
    // Un ejercicio se considera completado si el usuario respondió TODAS sus preguntas
    if (session.completedEjercicios.value.isEmpty) {
      final userAnswers = respuestasUsuario.where((r) => r['id_usuario'] == userId);
      final answeredPreguntaIds = userAnswers.map<int>((r) => r['id_pregunta'] as int).toSet();

      final completedEjs = <int>{};
      for (final ej in ejercicios) {
        if (ej.preguntas.isEmpty) continue;
        final allAnswered = ej.preguntas.every((p) => answeredPreguntaIds.contains(p.idPregunta));
        if (allAnswered) {
          completedEjs.add(ej.idEjercicio);
        }
      }
      if (completedEjs.isNotEmpty) {
        session.completedEjercicios.value = completedEjs;
      }
    }

    // ── Semilla: Lecciones guardadas ──────────────────────────────────────
    if (session.savedLecciones.value.isEmpty) {
      final savedLecs = guardados
          .where((g) => g['id_usuario'] == userId)
          .map<int>((g) => g['id_leccion'] as int)
          .toSet();
      if (savedLecs.isNotEmpty) {
        session.savedLecciones.value = savedLecs;
      }
    }

    // ── Semilla: Cursos guardados ─────────────────────────────────────────
    if (session.savedCursos.value.isEmpty) {
      final savedCurs = guardadosCursos
          .where((g) => g['id_usuario'] == userId)
          .map<int>((g) => g['id_curso'] as int)
          .toSet();
      if (savedCurs.isNotEmpty) {
        session.savedCursos.value = savedCurs;
      }
    }
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
        'seguidores': seguidores,
        'discusiones': discusiones.map((d) => DiscusionDto.toJson(d)).toList(),
        'comentarios': comentarios.map((c) => ComentarioDto.toJson(c)).toList(),
        'ejercicios': ejercicios.map((e) => EjercicioDto.toJson(e)).toList(),
        'preguntas': preguntas.map((p) => PreguntaDto.toJson(p)).toList(),
        'opciones': opciones.map((o) => OpcionDto.toJson(o)).toList(),
        'reportes': reportes,
        'lecciones_cursos': leccionesCursos,
        'calificaciones': calificaciones.map((c) => CalificacionDto.toJson(c)).toList(),
        'progreso_usuario': progresoUsuario,
        'respuestas_usuario': respuestasUsuario,
        'guardados': guardados,
        'guardados_cursos': guardadosCursos,
        'rachas': rachas,
        'notificaciones': notificaciones,
      };
      await prefs.setString(_storageKey, json.encode(fullData));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Error saving central data: $e");
    }
  }

  void guardarDatos() {
    _save();
  }

  // ── Racha (Streak) ──────────────────────────────────────────────────────────

  /// Obtiene la racha de un usuario. Retorna null si no existe.
  Map<String, dynamic>? getRacha(int idUsuario) {
    try {
      return rachas.firstWhere((r) => r['id_usuario'] == idUsuario);
    } catch (e) {
      return null;
    }
  }

  /// Registra actividad diaria para un usuario.
  /// Si hoy ya fue registrado, no hace nada.
  /// Si no, agrega hoy a la lista y recalcula la racha consecutiva.
  void registrarActividad(int idUsuario) {
    if (idUsuario == 0) return;

    final hoy = DateTime.now();
    final hoyStr = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    // Buscar la racha existente o crear una nueva
    var rachaIdx = rachas.indexWhere((r) => r['id_usuario'] == idUsuario);

    if (rachaIdx == -1) {
      rachas.add({
        'id_usuario': idUsuario,
        'dias_actividad': <String>[hoyStr],
        'racha_actual': 1,
      });
    } else {
      final dias = List<String>.from(rachas[rachaIdx]['dias_actividad'] ?? []);

      // Si hoy ya está registrado, no hacer nada
      if (dias.contains(hoyStr)) return;

      dias.add(hoyStr);
      dias.sort(); // Mantener ordenado

      // Recalcular racha consecutiva (días consecutivos hacia atrás desde hoy)
      int racha = 1;
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
  }

  // ── Operaciones de Escritura ───────────────────────────────────────────────
  void updateUsuario(Usuario usuario) {
    final idx = usuarios.indexWhere((u) => u.idUsuario == usuario.idUsuario);
    if (idx != -1) {
      usuarios[idx] = usuario;
      
      final dtoIdx = usuariosDto.indexWhere((u) => u.idUsuario == usuario.idUsuario);
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
    }
  }

  void addCurso(Curso curso) {
    cursos.add(curso);
    registrarActividad(AppSession().usuarioId ?? 0);
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
    registrarActividad(AppSession().usuarioId ?? 0);
    _save();
  }

  void updateLeccion(Leccion leccion) {
    final idx = lecciones.indexWhere((l) => l.idLeccion == leccion.idLeccion);
    if (idx != -1) {
      lecciones[idx] = leccion;
      _save();
    }
  }

  void addCapitulo(Capitulo capitulo) {
    capitulos.add(capitulo);
    _save();
  }

  void updateCapitulo(Capitulo capitulo) {
    final idx = capitulos.indexWhere((c) => c.idCapitulo == capitulo.idCapitulo);
    if (idx != -1) {
      capitulos[idx] = capitulo;
      _save();
    }
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

  // ── Operaciones Ejercicios ─────────────────────────────────────────────────
  void addEjercicio(Ejercicio e) {
    ejercicios.add(e);
    // Re-anidar en el capítulo correspondiente
    final capIdx = capitulos.indexWhere((c) => c.idCapitulo == e.idCapitulo);
    if (capIdx != -1) {
      final cap = capitulos[capIdx];
      capitulos[capIdx] = cap.copyWith(
        ejercicios: [...cap.ejercicios, e],
      );
    }
    _save();
  }

  void updateEjercicio(Ejercicio e) {
    final idx = ejercicios.indexWhere((x) => x.idEjercicio == e.idEjercicio);
    if (idx != -1) {
      ejercicios[idx] = e;
      // Re-anidar en el capítulo
      final capIdx = capitulos.indexWhere((c) => c.idCapitulo == e.idCapitulo);
      if (capIdx != -1) {
        final cap = capitulos[capIdx];
        final updatedEjs = cap.ejercicios.map(
          (x) => x.idEjercicio == e.idEjercicio ? e : x,
        ).toList();
        capitulos[capIdx] = cap.copyWith(ejercicios: updatedEjs);
      }
      _save();
    }
  }

  void removeEjercicio(int idEjercicio) {
    final ej = ejercicios.firstWhere(
      (e) => e.idEjercicio == idEjercicio,
      orElse: () => const Ejercicio(idEjercicio: -1, idCapitulo: -1, tipo: TipoEjercicio.multipleChoice, titulo: '', descripcion: ''),
    );
    ejercicios.removeWhere((e) => e.idEjercicio == idEjercicio);
    // Limpiar preguntas y opciones asociadas
    final pregIds = preguntas.where((p) => p.idEjercicioFk == idEjercicio).map((p) => p.idPregunta).toSet();
    opciones.removeWhere((o) => pregIds.contains(o.idPreguntaFk));
    preguntas.removeWhere((p) => p.idEjercicioFk == idEjercicio);
    // Re-anidar en el capítulo
    if (ej.idCapitulo != -1) {
      final capIdx = capitulos.indexWhere((c) => c.idCapitulo == ej.idCapitulo);
      if (capIdx != -1) {
        final cap = capitulos[capIdx];
        capitulos[capIdx] = cap.copyWith(
          ejercicios: cap.ejercicios.where((e) => e.idEjercicio != idEjercicio).toList(),
        );
      }
    }
    _save();
  }

  void addPregunta(Pregunta p) {
    preguntas.add(p);
    // Re-anidar en el ejercicio correspondiente
    final ejIdx = ejercicios.indexWhere((e) => e.idEjercicio == p.idEjercicioFk);
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
  }

  void addOpcion(Opcion o) {
    opciones.add(o);
    // Re-anidar en la pregunta correspondiente
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
  }

  // ── Operaciones Discusión ─────────────────────────────────────────────────
  void addDiscusion(Discusion d) {
    discusiones.add(d);
    _save();
  }

  void addComentario(Comentario c) {
    comentarios.add(c);
    _save();
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
    if (idx != -1) {
      if (seguidores[idx]['estado'] == 'activo') {
        seguidores[idx]['estado'] = 'bloqueado';
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
      
      notificaciones.insert(0, {
        'id': generateId(),
        'id_usuario_fk': idSeguido,
        'tipo': 'follow',
        'id_referencia': idSeguidor,
        'mensaje': '$nombreSeguidor ha comenzado a seguirte.',
        'leida': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    _save();
  }

  int getFollowersCount(int idUsuario) {
    return seguidores.where((s) => s['id_seguido'] == idUsuario && s['estado'] == 'activo').length;
  }

  int getFollowingCount(int idUsuario) {
    return seguidores.where((s) => s['id_seguidor'] == idUsuario && s['estado'] == 'activo').length;
  }

  // ── Notificaciones ────────────────────────────────────────────────────────
  void marcarNotificacionesComoLeidas(int idUsuario) {
    bool changed = false;
    for (var n in notificaciones) {
      if (n['id_usuario_fk'] == idUsuario && n['leida'] == false) {
        n['leida'] = true;
        changed = true;
      }
    }
    if (changed) _save();
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
  int nextMaterialId() =>
      _nextId(materiales, (m) => (m as MaterialEducativo).idMaterial);
  int nextEjercicioId() =>
      _nextId(ejercicios, (e) => (e as Ejercicio).idEjercicio);
  int nextPreguntaId() =>
      _nextId(preguntas, (p) => (p as Pregunta).idPregunta);
  int nextOpcionId() =>
      _nextId(opciones, (o) => (o as Opcion).idOpcion);

  int nextReporteId() {
    if (reportes.isEmpty) return 1;
    return reportes
        .map<int>((r) => (r['id_reporte'] as int?) ?? 0)
        .reduce((a, b) => a > b ? a : b) + 1;
  }

  // Generador de IDs único para nuevos registros locales
  // Se usa microsegundos para minimizar riesgo de colisión en ráfagas.
  int generateId() => DateTime.now().microsecondsSinceEpoch;

  // ── Operaciones de Reportes ────────────────────────────────────────────────
  void addReporte({
    required int idUsuarioFk,
    required String entidadTipo,
    required int entidadId,
    required String motivo,
  }) {
    final nuevoReporte = {
      'id_reporte': nextReporteId(),
      'id_usuario_fk': idUsuarioFk,
      'entidad_tipo': entidadTipo,
      'entidad_id': entidadId,
      'motivo': motivo,
      'created_at': DateTime.now().toIso8601String(),
    };
    reportes.add(nuevoReporte);
    _save();
  }

  // ── Operaciones Material Educativo ──────────────────────────────────────────
  void addMaterial(MaterialEducativo m) {
    materiales.add(m);
    _save();
  }

  void updateMaterial(MaterialEducativo m) {
    final idx = materiales.indexWhere((x) => x.idMaterial == m.idMaterial);
    if (idx != -1) {
      materiales[idx] = m;
      _save();
    }
  }

  void removeMaterial(int id) {
    materiales.removeWhere((m) => m.idMaterial == id);
    _save();
  }

  List<MaterialEducativo> materialesDeLeccion(int idLeccion) {
    return materiales.where((m) => m.idLeccionFk == idLeccion).toList();
  }

  // ── Calificaciones (Reseñas Dinámicas) ─────────────────────────────────────
  
  Future<(double, bool)> agregarOActualizarCalificacion(
      int idObjeto, String tipoObjeto, int idUsuario, int valor) async {
    bool isUpdate = false;
    // 1. Buscar si ya existe una calificación de este usuario para este objeto
    final index = calificaciones.indexWhere((c) =>
        c.idObjetoFk == idObjeto &&
        c.tipoObjeto == tipoObjeto &&
        c.idUsuarioFk == idUsuario);

    if (index >= 0) {
      // Actualizar existente
      calificaciones[index] = calificaciones[index].copyWith(valor: valor);
      isUpdate = true;
    } else {
      // Crear nueva
      final newId = calificaciones.isEmpty
          ? 1
          : calificaciones.map((c) => c.idCalificacion).reduce((a, b) => a > b ? a : b) + 1;
      calificaciones.add(Calificacion(
        idCalificacion: newId,
        idObjetoFk: idObjeto,
        tipoObjeto: tipoObjeto,
        idUsuarioFk: idUsuario,
        valor: valor,
      ));
    }

    // 2. Calcular nuevo promedio ponderado
    final calificacionesDelObjeto = calificaciones
        .where((c) => c.idObjetoFk == idObjeto && c.tipoObjeto == tipoObjeto)
        .toList();

    double nuevoPromedio = 0.0;
    if (calificacionesDelObjeto.isNotEmpty) {
      final suma = calificacionesDelObjeto.fold<int>(0, (sum, c) => sum + c.valor);
      nuevoPromedio = suma / calificacionesDelObjeto.length;
    }

    // 3. Modificar la memoria del objeto destino (Leccion o Curso)
    if (tipoObjeto == 'leccion') {
      final iLeccion = lecciones.indexWhere((l) => l.idLeccion == idObjeto);
      if (iLeccion >= 0) {
        lecciones[iLeccion] = lecciones[iLeccion].copyWith(rating: double.parse(nuevoPromedio.toStringAsFixed(1)));
        nuevoPromedio = lecciones[iLeccion].rating; // Mantenemos 1 decimal congruente
      }
    } else if (tipoObjeto == 'curso') {
      final iCurso = cursos.indexWhere((c) => c.idCurso == idObjeto);
      if (iCurso >= 0) {
        cursos[iCurso] = cursos[iCurso].copyWith(rating: double.parse(nuevoPromedio.toStringAsFixed(1)));
        nuevoPromedio = cursos[iCurso].rating;
      }
    }

    // 4. Persistir cambios 
    await _save();
    return (nuevoPromedio, isUpdate);
  }
}
