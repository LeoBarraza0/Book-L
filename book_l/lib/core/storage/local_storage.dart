import 'package:shared_preferences/shared_preferences.dart';

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

  // ── Campos en memoria (cargados desde disco en init) ───────────────────────
  String? token;
  int? usuarioId;
  String? nombreCompleto;
  String? rol;         // 'Estudiante' | 'Profesor' | 'Administrador'
  String? programa;
  bool temaOscuro = false;
  String idioma = 'es';

  late SharedPreferences _prefs;
  bool _initialized = false;

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

    _initialized = true;
  }

  // ── Consultas ──────────────────────────────────────────────────────────────
  bool get estaLogueado => token != null && token!.isNotEmpty;
  bool get esProfesor => rol == 'Profesor' || rol == 'Administrador';

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
  }) async {
    if (temaOscuro != null) {
      this.temaOscuro = temaOscuro;
      await _prefs.setBool(_kTemaOscuro, temaOscuro);
    }
    if (idioma != null) {
      this.idioma = idioma;
      await _prefs.setString(_kIdioma, idioma);
    }
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
  }
}
