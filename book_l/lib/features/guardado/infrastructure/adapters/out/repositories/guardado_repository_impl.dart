import 'package:book_l/features/guardado/application/ports/out/guardado_repository.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de guardados (favoritos).
class GuardadoRepositoryImpl implements GuardadoRepository {
  final BooklService _service = BooklService();
  final AppSession _session = AppSession();

  @override
  List<Leccion> getSavedLecciones() {
    final savedIds = _session.savedLecciones.value;
    return _service.lecciones
        .where((l) => savedIds.contains(l.idLeccion))
        .toList();
  }

  @override
  List<Curso> getSavedCursos() {
    final savedIds = _session.savedCursos.value;
    return _service.cursos.where((c) => savedIds.contains(c.idCurso)).toList();
  }

  @override
  void toggleSavedLeccion(int idLeccion) {
    _session.toggleSavedLeccion(idLeccion);
  }

  @override
  void toggleSavedCurso(int idCurso) {
    _session.toggleSavedCurso(idCurso);
  }

  @override
  bool isLeccionSaved(int idLeccion) {
    return _session.savedLecciones.value.contains(idLeccion);
  }

  @override
  bool isCursoSaved(int idCurso) {
    return _session.savedCursos.value.contains(idCurso);
  }
}
