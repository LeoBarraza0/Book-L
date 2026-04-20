import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/curso_model.dart';

class LocalDbService {
  static const String _coursesKey = 'cached_courses';
  static final LocalDbService instance = LocalDbService._internal();

  LocalDbService._internal();

  /// Gets a new unique ID (int)
  int generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Loads courses, preferring cached versions, falls back to assets
  Future<List<CursoModel>> loadCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_coursesKey);

      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> jsonMap = jsonDecode(cachedData);
        return jsonMap.map((json) => CursoModel.fromJson(json)).toList();
      } else {
        // Fallback to initial assets
        final String jsonString =
            await rootBundle.loadString('assets/data/mis_cursos.json');
        final List<dynamic> jsonMap = jsonDecode(jsonString);
        final initialCourses =
            jsonMap.map((json) => CursoModel.fromJson(json)).toList();

        // Save initial state into cache so we don't start from scratch again next time
        await saveCourses(initialCourses);
        return initialCourses;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading courses from Local DB: $e");
      }
      return [];
    }
  }

  /// Saves the current course list to SharedPreferences
  Future<void> saveCourses(List<CursoModel> courses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData =
          jsonEncode(courses.map((e) => e.toJson()).toList());
      await prefs.setString(_coursesKey, encodedData);
    } catch (e) {
      if (kDebugMode) {
        print("Error saving courses to Local DB: $e");
      }
    }
  }

  /// Wipe totally (for testing/debugging purposes)
  Future<void> clearDB() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coursesKey);
  }
}
