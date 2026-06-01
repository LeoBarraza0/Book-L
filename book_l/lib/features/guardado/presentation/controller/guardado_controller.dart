import 'package:flutter/foundation.dart';
import '../../data/repositories/guardado_repository_impl.dart';
import '../../../leccion/domain/entities/leccion.dart';
import '../../../curso/domain/entities/curso.dart';
import '../../domain/usecases/get_guardados_usecase.dart';
import '../../domain/usecases/toggle_guardado_usecase.dart';

/// Controlador singleton para la gestión de elementos guardados (favoritos).
class GuardadoController extends ChangeNotifier {
  static final GuardadoController _instance = GuardadoController._internal();
  factory GuardadoController() => _instance;

  final GuardadoRepositoryImpl _repo;
  final GetGuardadosUseCase _getGuardadosUseCase;
  final ToggleGuardadoUseCase _toggleGuardadoUseCase;

  GuardadoController._internal()
      : _repo = GuardadoRepositoryImpl(),
        _getGuardadosUseCase = GetGuardadosUseCase(GuardadoRepositoryImpl()),
        _toggleGuardadoUseCase = ToggleGuardadoUseCase(
          GuardadoRepositoryImpl(),
          GetGuardadosUseCase(GuardadoRepositoryImpl()),
        );

  /// Retorna las lecciones guardadas del usuario
  List<Leccion> getSavedLecciones() {
    return _getGuardadosUseCase().lecciones;
  }

  /// Retorna los cursos guardados del usuario
  List<Curso> getSavedCursos() {
    return _getGuardadosUseCase().cursos;
  }

  /// Alterna el estado de guardado de una lección
  void toggleSavedLeccion(int idLeccion) {
    _toggleGuardadoUseCase(
      ToggleGuardadoParams(id: idLeccion, tipo: TipoGuardado.leccion),
    );
    notifyListeners();
  }

  /// Alterna el estado de guardado de un curso
  void toggleSavedCurso(int idCurso) {
    _toggleGuardadoUseCase(
      ToggleGuardadoParams(id: idCurso, tipo: TipoGuardado.curso),
    );
    notifyListeners();
  }

  /// Verifica si una lección está en favoritos
  bool isLeccionSaved(int idLeccion) {
    return _repo.isLeccionSaved(idLeccion);
  }

  /// Verifica si un curso está en favoritos
  bool isCursoSaved(int idCurso) {
    return _repo.isCursoSaved(idCurso);
  }

  // ignore: must_call_super
  @override
  void dispose() {
    // Singleton — no debe destruirse con el ciclo de vida de la pantalla
  }
}
