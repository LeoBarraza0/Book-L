import 'package:flutter/foundation.dart';
import '../../domain/usecases/calificar_leccion_usecase.dart';
import '../../domain/usecases/calificar_curso_usecase.dart';
import '../../data/repositories/calificacion_repository_impl.dart';
import 'calificacion_state.dart';

class CalificacionController extends ChangeNotifier {
  static final CalificacionController _instance = CalificacionController._internal();
  factory CalificacionController() => _instance;
  CalificacionController._internal();

  CalificacionState _state = CalificacionState();
  CalificacionState get state => _state;

  // Casos de uso inyectados con la implementación del repositorio (conectado a BooklService)
  final _calificarLeccion = CalificarLeccionUseCase(CalificacionRepositoryImpl());
  final _calificarCurso = CalificarCursoUseCase(CalificacionRepositoryImpl());

  Future<(double, bool)?> calificarLeccion(int idLeccion, int valor) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final res = await _calificarLeccion.execute(idLeccion, valor);
      _state = _state.copyWith(
        isLoading: false,
        nuevoRating: res.$1,
        isUpdate: res.$2,
      );
      notifyListeners();
      return res;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
      return null;
    }
  }

  Future<(double, bool)?> calificarCurso(int idCurso, int valor) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final res = await _calificarCurso.execute(idCurso, valor);
      _state = _state.copyWith(
        isLoading: false,
        nuevoRating: res.$1,
        isUpdate: res.$2,
      );
      notifyListeners();
      return res;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
      notifyListeners();
      return null;
    }
  }
}
