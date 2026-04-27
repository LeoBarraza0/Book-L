import 'package:shared_preferences/shared_preferences.dart';

/// Clase Singleton para manejar SharedPreferences
class PreferencesService {
  // Instancia privada única
  static final PreferencesService _instance = PreferencesService._internal();

  // Factory que siempre retorna la misma instancia
  factory PreferencesService() {
    return _instance;
  }

  // Constructor privado
  PreferencesService._internal();

  SharedPreferences? _prefs;

  /// Inicializa SharedPreferences
  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Guardar nombre
  Future saveName(String name) async {
    await _prefs?.setString("name", name);
  }

  /// Obtener nombre
  String getName() {
    return _prefs?.getString("name") ?? "";
  }

  /// Guardar género
  Future saveGender(String gender) async {
    await _prefs?.setString("gender", gender);
  }

  /// Obtener género
  String getGender() {
    return _prefs?.getString("gender") ?? "";
  }

  /// Guardar color
  Future saveColor(String color) async {
    await _prefs?.setString("color", color);
  }

  /// Obtener color
  String getColor() {
    return _prefs?.getString("color") ?? "blue";
  }
}
