import 'package:flutter/material.dart';
import '../domain/models/curso_model.dart';
import '../domain/models/leccion_model.dart';
import '../domain/models/capitulo_model.dart';
import '../../core/infrastructure/services/bookl_service.dart';
import '../../features/curso/domain/models/curso.dart';
import '../../features/leccion/domain/models/leccion.dart';
import '../../features/leccion/domain/models/capitulo.dart';

/// Singleton in-memory repository for locally created courses.
/// Now acts as a bridge to [BooklService] for centralized architecture.
class CourseRepository {
  CourseRepository._internal() {
    // Sync with BooklService
    BooklService().addListener(_syncFromCentral);
    _syncFromCentral();
  }
  static final CourseRepository instance = CourseRepository._internal();

  /// Notifier holding the list of created courses (filtered from BooklService).
  final ValueNotifier<List<CursoModel>> coursesNotifier =
      ValueNotifier<List<CursoModel>>([]);

  List<CursoModel> get courses => coursesNotifier.value;

  /// Sincroniza desde BooklService convirtiendo Entidades → Modelos de UI.
  void _syncFromCentral() {
    final allCursos = BooklService().cursos;
    // Here we can filter if we only want "local" courses,
    // but the user wants "everything in their JSON".
    // We convert Entities back to Models for the UI if needed,
    // or just pass them through if the UI can handle them.
    // For now, let's keep the UI models by converting.

    coursesNotifier.value = allCursos
        .map((c) => CursoModel(
              id: c.idCurso,
              idUsuarioFk: c.idUsuarioFk,
              nombre: c.nombre,
              descripcion: (c.contenido?.isNotEmpty ?? false)
                  ? (c.contenido!.first['titulo'] ?? '').toString()
                  : '',
              rating: c.rating,
              duracion: c.duracion,
              estudiantes: c.estudiantes,
              progreso: c.progreso,
              tagColor: c.tagColor != null
                  ? Color(c.tagColor!)
                  : const Color(0xFF4DC130),
              esNuevo: c.esNuevo,
              lecciones: [],
            ))
        .toList();
  }

  /// Persiste un nuevo curso (y sus lecciones/capítulos anidados) en BooklService.
  void addCourse(CursoModel model) {
    final entity = Curso(
      idCurso: model.id,
      idUsuarioFk: model.idUsuarioFk,
      nombre: model.nombre,
      contenido: model.descripcion.isNotEmpty
          ? [
              {'titulo': model.descripcion}
            ]
          : null,
      rating: model.rating,
      duracion: model.duracion,
      estudiantes: model.estudiantes,
      progreso: model.progreso,
      tagColor: model.tagColor.value,
      esNuevo: model.esNuevo,
      estado: 'activo',
      createdAt: DateTime.now(),
    );
    BooklService().addCurso(entity);

    for (var lessonModel in model.lecciones) {
      addLessonToCourse(model.id, lessonModel);
    }
  }

  /// Persiste una lección asociada a un curso en BooklService.
  void addLessonToCourse(int courseId, LeccionModel lesson) {
    final entity = Leccion(
      idLeccion: lesson.id,
      idUsuarioFk: 1,
      nombre: lesson.nombre,
      rating: lesson.rating,
      duracion: lesson.duracion,
      estudiantes: lesson.estudiantes,
      progreso: lesson.progreso,
      tagColor: lesson.tagColor,
      esNuevo: lesson.esNuevo,
      estado: 'activa',
      createdAt: DateTime.now(),
    );
    BooklService().addLeccion(entity, idCurso: courseId);

    for (var cap in lesson.capitulos) {
      addChapterToLesson(courseId, lesson.id, cap);
    }
  }

  /// Persiste un capítulo en BooklService, vinculado relacionalmente a la lección.
  void addChapterToLesson(int courseId, int lessonId, CapituloModel model) {
    final entity = Capitulo(
      idCapitulo: model.id,
      idLeccion: lessonId,
      nombre: model.nombre,
      contenido: model.secciones,
      tiempoTotal: 0,
    );
    BooklService().addCapitulo(entity);
  }

  /// Elimina un curso y sus relaciones del almacenamiento central.
  void removeCourse(int id) => BooklService().removeCurso(id);

  /// Vacía todo el almacenamiento y recarga desde el asset JSON base.
  void clear() => BooklService().clearAllData();
}
