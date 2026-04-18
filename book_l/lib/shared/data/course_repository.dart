import 'package:flutter/foundation.dart';
import '../domain/models/curso_model.dart';
import '../domain/models/leccion_model.dart';
import '../domain/models/capitulo_model.dart';
import 'local_db_service.dart';

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

  /// Loads initial dummy data from LocalDB (or fallback to assets/data).
  Future<void> loadInitialCourses() async {
    try {
      final initialCourses = await LocalDbService.instance.loadCourses();
      coursesNotifier.value = initialCourses;
    } catch (e) {
      if (kDebugMode) {
        print("Error loading initial courses: $e");
      }
    }
  }

  Future<void> _saveToLocalDB() async {
    await LocalDbService.instance.saveCourses(coursesNotifier.value);
  }

  void addCourse(CursoModel course) {
    coursesNotifier.value = [...coursesNotifier.value, course];
    _saveToLocalDB();
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
      _saveToLocalDB();
    }
  }

  void updateLessonInCourse(String courseId, LeccionModel updatedLesson) {
    final list = coursesNotifier.value;
    final index = list.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final course = list[index];
      final lessonIndex = course.lecciones.indexWhere((l) => l.id == updatedLesson.id);
      if (lessonIndex != -1) {
        final newLessons = List<LeccionModel>.from(course.lecciones);
        newLessons[lessonIndex] = updatedLesson;
        
        final updatedCourse = course.copyWith(lecciones: newLessons);
        final newList = List<CursoModel>.from(list);
        newList[index] = updatedCourse;
        coursesNotifier.value = newList;
        _saveToLocalDB();
      }
    }
  }

  void addChapterToLesson(String courseId, String lessonId, CapituloModel chapter) {
    final list = coursesNotifier.value;
    final index = list.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      final course = list[index];
      final lessonIndex = course.lecciones.indexWhere((l) => l.id == lessonId);
      if (lessonIndex != -1) {
        final lesson = course.lecciones[lessonIndex];
        final updatedLesson = lesson.copyWith(
          capitulos: [...lesson.capitulos, chapter],
        );
        final newLessons = List<LeccionModel>.from(course.lecciones);
        newLessons[lessonIndex] = updatedLesson;
        
        final updatedCourse = course.copyWith(lecciones: newLessons);
        final newList = List<CursoModel>.from(list);
        newList[index] = updatedCourse;
        coursesNotifier.value = newList;
        _saveToLocalDB();
      }
    }
  }

  void updateCourseState() {
     // A handy method when nested things are mutated
     coursesNotifier.value = List.from(coursesNotifier.value);
     _saveToLocalDB();
  }

  void removeCourse(String id) {
    coursesNotifier.value =
        coursesNotifier.value.where((c) => c.id != id).toList();
    _saveToLocalDB();
  }

  void clear() {
    coursesNotifier.value = [];
    _saveToLocalDB();
  }
}
