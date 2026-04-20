import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/leccion_model.dart';

/// Repositorio singleton de lecciones independientes (no asociadas a un curso).
/// Persiste en SharedPreferences bajo la clave [_leccionesKey].
/// Reactivo a través de [ValueNotifier] para que los widgets se reconstruyan
/// automáticamente cuando cambia la lista.
class LeccionRepository {
  LeccionRepository._internal() {
    _loadInitial();
  }
  static final LeccionRepository instance = LeccionRepository._internal();

  static const String _leccionesKey = 'standalone_lecciones';

  final ValueNotifier<List<LeccionModel>> leccionesNotifier =
      ValueNotifier<List<LeccionModel>>([]);

  List<LeccionModel> get lecciones => leccionesNotifier.value;

  bool get hasLecciones => leccionesNotifier.value.isNotEmpty;

  // ── Carga inicial ────────────────────────────────────────────────────────────
  Future<void> _loadInitial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_leccionesKey);

      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        leccionesNotifier.value =
            decoded.map((e) => LeccionModel.fromJson(e)).toList();
      }
      // Si no hay datos guardados, la lista queda vacía (no hay seed de lecciones standalone)
    } catch (e) {
      if (kDebugMode) print('LeccionRepository._loadInitial error: $e');
    }
  }

  // ── Persistencia interna ─────────────────────────────────────────────────────
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(leccionesNotifier.value.map((e) => e.toJson()).toList());
      await prefs.setString(_leccionesKey, encoded);
    } catch (e) {
      if (kDebugMode) print('LeccionRepository._save error: $e');
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<void> addLeccion(LeccionModel leccion) async {
    leccionesNotifier.value = [...leccionesNotifier.value, leccion];
    await _save();
  }

  Future<void> updateLeccion(LeccionModel updated) async {
    final list = List<LeccionModel>.from(leccionesNotifier.value);
    final idx = list.indexWhere((l) => l.id == updated.id);
    if (idx != -1) {
      list[idx] = updated;
      leccionesNotifier.value = list;
      await _save();
    }
  }

  Future<void> removeLeccion(int id) async {
    leccionesNotifier.value =
        leccionesNotifier.value.where((l) => l.id != id).toList();
    await _save();
  }

  LeccionModel? getLeccionById(int id) {
    try {
      return leccionesNotifier.value.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    leccionesNotifier.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_leccionesKey);
  }
}
