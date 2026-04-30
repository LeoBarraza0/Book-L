import '../../domain/repositories/guardado_repository.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../leccion/domain/entities/leccion.dart';
import '../../../curso/domain/entities/curso.dart';

/// Implementación del repositorio de guardados (favoritos).
/// Interacciona con BooklService y AppSession para obtener y persistir los datos.
class GuardadoRepositoryImpl implements GuardadoRepository {
  final BooklService _service = BooklService();
  final AppSession _session = AppSession();

  @override
  List<Leccion> getSavedLecciones() {
    final savedIds = _session.savedLecciones.value;
    return _service.lecciones.where((l) => savedIds.contains(l.idLeccion)).toList();
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
