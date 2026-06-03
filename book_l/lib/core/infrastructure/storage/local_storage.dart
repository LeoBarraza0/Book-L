import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bookl_service.dart';
import '../services/supabase_client.dart';

// Singleton de sesión activa — ÚNICA clase del proyecto que usa SharedPreferences.
//
// Qué persiste: token, id, nombre, rol, programa, tema, idioma.
// Qué NO persiste: listas, colecciones, datos de negocio (eso viene de BooklService).
//
// Uso: AppSession().init() en main.dart antes de runApp().
// Lectura: AppSession().nombreCompleto, AppSession().estaLogueado, etc.
class AppSession {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final AppSession _instance = AppSession._internal();
  factory AppSession() => _instance;
  AppSession._internal();

  // ── Claves SharedPreferences ───────────────────────────────────────────────
  static const _kToken = 'token';
  static const _kUsuarioId = 'usuario_id';
  static const _kNombreCompleto = 'nombre_completo';
  static const _kRol = 'rol';
  static const _kPrograma = 'programa';
  static const _kTemaOscuro = 'tema_oscuro';
  static const _kIdioma = 'idioma';
  static const _kTamanoFuente = 'tamano_fuente';
  static const _kSavedCursos = 'saved_cursos';
  static const _kSavedLecciones = 'saved_lecciones';
  static const _kOnboardingCompleted = 'onboarding_completed';
  static const _kCompletedCapitulos = 'completed_capitulos';
  static const _kCompletedEjercicios = 'completed_ejercicios';

  // ── Campos en memoria (cargados desde disco en init) ───────────────────────
  String? token;
  int? usuarioId;
  String? nombreCompleto;
  String? rol; // 'Estudiante' | 'Profesor' | 'Administrador'
  String? programa;
  bool temaOscuro = false;
  String idioma = 'es';
  String tamanoFuente = 'normal';
  bool onboardingCompleted = false;

  late SharedPreferences _prefs;
  bool _initialized = false;

  // Reactividad para los Favoritos
  final ValueNotifier<Set<int>> savedCursos = ValueNotifier<Set<int>>({});
  final ValueNotifier<Set<int>> savedLecciones = ValueNotifier<Set<int>>({});
  final ValueNotifier<Set<int>> completedCapitulos =
      ValueNotifier<Set<int>>({});
  final ValueNotifier<Set<int>> completedEjercicios =
      ValueNotifier<Set<int>>({});

  // Notifiers globales para la UI
  final ValueNotifier<bool> temaNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> fontScaleNotifier =
      ValueNotifier<String>('normal');

  // ── Inicialización ─────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();

    token = _prefs.getString(_kToken);
    usuarioId = _prefs.getInt(_kUsuarioId);
    nombreCompleto = _prefs.getString(_kNombreCompleto);
    rol = _prefs.getString(_kRol);
    programa = _prefs.getString(_kPrograma);
    temaOscuro = _prefs.getBool(_kTemaOscuro) ?? false;
    idioma = _prefs.getString(_kIdioma) ?? 'es';
    tamanoFuente = _prefs.getString(_kTamanoFuente) ?? 'normal';
    onboardingCompleted = _prefs.getBool(_kOnboardingCompleted) ?? false;

    temaNotifier.value = temaOscuro;
    fontScaleNotifier.value = tamanoFuente;

    final loadedCursos = _prefs.getStringList(_kSavedCursos) ?? [];
    savedCursos.value = loadedCursos
        .map((e) => int.tryParse(e) ?? -1)
        .where((id) => id != -1)
        .toSet();

    final loadedLecciones = _prefs.getStringList(_kSavedLecciones) ?? [];
    savedLecciones.value = loadedLecciones
        .map((e) => int.tryParse(e) ?? -1)
        .where((id) => id != -1)
        .toSet();

    final loadedCompletados = _prefs.getStringList(_kCompletedCapitulos) ?? [];
    completedCapitulos.value = loadedCompletados
        .map((e) => int.tryParse(e) ?? -1)
        .where((id) => id != -1)
        .toSet();

    final loadedCompletadosEj =
        _prefs.getStringList(_kCompletedEjercicios) ?? [];
    completedEjercicios.value = loadedCompletadosEj
        .map((e) => int.tryParse(e) ?? -1)
        .where((id) => id != -1)
        .toSet();

    _initialized = true;
  }

  // ── Consultas ──────────────────────────────────────────────────────────────
  bool get estaLogueado => token != null && token!.isNotEmpty;
  bool get esProfesor =>
      rol?.toLowerCase().contains('profesor') ?? false || esAdministrador;
  bool get esAdministrador => rol?.toLowerCase().contains('admin') ?? false;

  // ── Persistencia de sesión (llamado por auth_repository_impl al login) ─────
  Future<void> guardarSesion({
    required String token,
    required int usuarioId,
    required String nombreCompleto,
    required String rol,
    String? programa,
  }) async {
    this.token = token;
    this.usuarioId = usuarioId;
    this.nombreCompleto = nombreCompleto;
    this.rol = rol;
    this.programa = programa;

    await _prefs.setString(_kToken, token);
    await _prefs.setInt(_kUsuarioId, usuarioId);
    await _prefs.setString(_kNombreCompleto, nombreCompleto);
    await _prefs.setString(_kRol, rol);
    if (programa != null) await _prefs.setString(_kPrograma, programa);
  }

  // ── Persistencia de preferencias (llamado por configuracion_repository_impl)
  Future<void> guardarPreferencias({
    bool? temaOscuro,
    String? idioma,
    String? tamanoFuente,
  }) async {
    if (temaOscuro != null) {
      this.temaOscuro = temaOscuro;
      temaNotifier.value = temaOscuro;
      await _prefs.setBool(_kTemaOscuro, temaOscuro);
    }
    if (idioma != null) {
      this.idioma = idioma;
      await _prefs.setString(_kIdioma, idioma);
    }
    if (tamanoFuente != null) {
      this.tamanoFuente = tamanoFuente;
      fontScaleNotifier.value = tamanoFuente;
      await _prefs.setString(_kTamanoFuente, tamanoFuente);
    }
  }

  // ── Modificadores de Favoritos ─────────────────────────────────────────────

  void toggleSavedCurso(int idCurso) {
    final current = Set<int>.from(savedCursos.value);
    final wasAdded = !current.contains(idCurso);
    if (current.contains(idCurso)) {
      current.remove(idCurso);
    } else {
      current.add(idCurso);
    }
    savedCursos.value = current;
    _prefs.setStringList(
        _kSavedCursos, current.map((e) => e.toString()).toList());

    if (usuarioId != null && SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        if (wasAdded) {
          client.from('tbl_guardado_curso').insert(Map<String, dynamic>.from({
            'idusuario': usuarioId!,
            'idcurso': idCurso,
          })).then((_) => null,
              onError: (e) => debugPrint("Supabase saved curso error: $e"));
        } else {
          client
              .from('tbl_guardado_curso')
              .delete()
              .eq('idusuario', usuarioId!)
              .eq('idcurso', idCurso)
              .then((_) => null,
                  onError: (e) =>
                      debugPrint("Supabase unsaved curso error: $e"));
        }
      } catch (e) {
        debugPrint("Error syncing saved curso: $e");
      }
    }
  }

  void toggleSavedLeccion(int idLeccion) {
    final current = Set<int>.from(savedLecciones.value);
    final wasAdded = !current.contains(idLeccion);
    if (current.contains(idLeccion)) {
      current.remove(idLeccion);
    } else {
      current.add(idLeccion);
    }
    savedLecciones.value = current;
    _prefs.setStringList(
        _kSavedLecciones, current.map((e) => e.toString()).toList());

    if (usuarioId != null && SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        if (wasAdded) {
          client.from('tbl_guardado_leccion').insert(Map<String, dynamic>.from({
            'idusuario': usuarioId!,
            'idleccion': idLeccion,
          })).then((_) => null,
              onError: (e) => debugPrint("Supabase saved leccion error: $e"));
        } else {
          client
              .from('tbl_guardado_leccion')
              .delete()
              .eq('idusuario', usuarioId!)
              .eq('idleccion', idLeccion)
              .then((_) => null,
                  onError: (e) =>
                      debugPrint("Supabase unsaved leccion error: $e"));
        }
      } catch (e) {
        debugPrint("Error syncing saved leccion: $e");
      }
    }
  }

  void marcarCapituloCompletado(int idCapitulo, bool completado) {
    final current = Set<int>.from(completedCapitulos.value);
    if (completado) {
      current.add(idCapitulo);
      // Registrar actividad para la racha
      BooklService().registrarActividad(usuarioId ?? 0);
    } else {
      current.remove(idCapitulo);
    }
    completedCapitulos.value = current;
    _prefs.setStringList(
        _kCompletedCapitulos, current.map((e) => e.toString()).toList());

    if (usuarioId != null && SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        client.from('tbl_progreso_usuario').upsert(Map<String, dynamic>.from({
          'id_usuariofk': usuarioId!,
          'id_capitulofk': idCapitulo,
          'estado': completado ? 'completada' : 'no_iniciada',
        }), onConflict: 'id_usuariofk,id_capitulofk').then((_) => null,
            onError: (e) => debugPrint("Supabase progress error: $e"));
      } catch (e) {
        debugPrint("Error syncing completed chapter: $e");
      }
    }
  }

  void marcarEjercicioCompletado(int idEjercicio, int idCapitulo) {
    final current = Set<int>.from(completedEjercicios.value);
    current.add(idEjercicio);
    completedEjercicios.value = current;
    _prefs.setStringList(
        _kCompletedEjercicios, current.map((e) => e.toString()).toList());
    // Registrar actividad para la racha
    BooklService().registrarActividad(usuarioId ?? 0);
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    token = null;
    usuarioId = null;
    nombreCompleto = null;
    rol = null;
    programa = null;
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUsuarioId);
    await _prefs.remove(_kNombreCompleto);
    await _prefs.remove(_kRol);
    await _prefs.remove(_kPrograma);
    await _prefs.remove(_kSavedCursos);
    await _prefs.remove(_kSavedLecciones);
    await _prefs.remove(_kCompletedCapitulos);
    savedCursos.value = {};
    savedLecciones.value = {};
    completedCapitulos.value = {};
  }

  Future<void> setOnboardingCompleted(bool value) async {
    onboardingCompleted = value;
    await _prefs.setBool(_kOnboardingCompleted, value);
  }
}