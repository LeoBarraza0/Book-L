import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../domain/models/curso_model.dart';
import '../domain/models/leccion_model.dart';

/// Singleton in-memory repository for locally created courses.
/// Uses [ValueNotifier] so widgets can reactively rebuild only
/// the section that shows courses — not the entire profile tree.
class CourseRepository {
  CourseRepository._internal() {
    // Initial load
    loadInitialCourses();
  }
  static final CourseRepository instance = CourseRepository._internal();

  /// Notifier holding the list of created courses.
  final ValueNotifier<List<CursoModel>> coursesNotifier =
      ValueNotifier<List<CursoModel>>([]);

  List<CursoModel> get courses => coursesNotifier.value;

  bool get hasCourses => coursesNotifier.value.isNotEmpty;

  /// Loads initial dummy data from local JSON.
  Future<void> loadInitialCourses() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/mis_cursos.json');
      final List<dynamic> jsonMap = jsonDecode(jsonString);
      final initialCourses = jsonMap.map((json) => CursoModel.fromJson(json)).toList();
      coursesNotifier.value = initialCourses;
    } catch (e) {
      if (kDebugMode) {
        print("Error loading initial courses: $e");
      }
    }
  }

  void addCourse(CursoModel course) {
    coursesNotifier.value = [...coursesNotifier.value, course];
  }

  void addLessonToCourse(String courseId, LeccionModel lesson) {
    final list = coursesNotifier.value;
    final index = list.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final course = list[index];
      final updatedCourse = course.copyWith(
        lecciones: [...course.lecciones, lesson],
      );
      final newList = List<CursoModel>.from(list);
      newList[index] = updatedCourse;
      coursesNotifier.value = newList;
    }
  }

  void removeCourse(String id) {
    coursesNotifier.value =
        coursesNotifier.value.where((c) => c.id != id).toList();
  }

  void clear() {
    coursesNotifier.value = [];
  }
}
