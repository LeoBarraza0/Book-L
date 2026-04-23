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
        'seguidores': seguidores,
        'discusiones': discusiones.map((d) => DiscusionDto.toJson(d)).toList(),
        'comentarios': comentarios.map((c) => ComentarioDto.toJson(c)).toList(),
        'ejercicios': ejercicios.map((e) => EjercicioDto.toJson(e)).toList(),
        'preguntas': preguntas.map((p) => PreguntaDto.toJson(p)).toList(),
        'opciones': opciones.map((o) => OpcionDto.toJson(o)).toList(),
        'reportes': reportes,
        'lecciones_cursos': leccionesCursos,
        'calificaciones': calificaciones.map((c) => CalificacionDto.toJson(c)).toList(),
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
    if (idx != -1) {
      if (seguidores[idx]['estado'] == 'activo') {
        seguidores[idx]['estado'] = 'bloqueado';
      } else {
        seguidores[idx]['estado'] = 'activo';
      }
    } else {
      seguidores.add({
        'id_seguidor': idSeguidor,
        'id_seguido': idSeguido,
        'estado': 'activo',
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

  // Generador de IDs único para nuevos registros locales
  // Se usa microsegundos para minimizar riesgo de colisión en ráfagas.
  int generateId() => DateTime.now().microsecondsSinceEpoch;

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
