import 'package:flutter/foundation.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/repositories/progreso_repository_impl.dart';
import '../../domain/usecases/get_progreso_usecase.dart';
import '../../domain/usecases/actualizar_progreso_usecase.dart';
import '../../domain/usecases/registrar_evento_usecase.dart';

class ProgresoController extends ChangeNotifier {
  static final ProgresoController _instance = ProgresoController._internal();
  factory ProgresoController() => _instance;

  final GetProgresoUseCase _getProgresoUseCase;
  final ActualizarProgresoUseCase _actualizarProgresoUseCase;
  final RegistrarEventoUseCase _registrarEventoUseCase;

  ProgresoController._internal()
      : _getProgresoUseCase = GetProgresoUseCase(ProgresoRepositoryImpl()),
        _actualizarProgresoUseCase = ActualizarProgresoUseCase(ProgresoRepositoryImpl()),
        _registrarEventoUseCase = RegistrarEventoUseCase(ProgresoRepositoryImpl());

  Map<String, dynamic> _progresoData = {};
  Map<String, dynamic> get progresoData => _progresoData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> cargarProgreso() async {
    final userId = AppSession().usuarioId;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    final data = await _getProgresoUseCase(userId);
    _progresoData = Map<String, dynamic>.from(data);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> marcarCapituloCompletado(int idCapitulo) async {
    final userId = AppSession().usuarioId;
    if (userId == null) return;

    await _actualizarProgresoUseCase(userId, idCapitulo, 'capitulo');
    await cargarProgreso();
  }

  Future<void> marcarEjercicioCompletado(int idEjercicio) async {
    final userId = AppSession().usuarioId;
    if (userId == null) return;

    await _actualizarProgresoUseCase(userId, idEjercicio, 'ejercicio');
    await cargarProgreso();
  }

  Future<void> registrarActividad() async {
    final userId = AppSession().usuarioId;
    if (userId == null) return;

    await _registrarEventoUseCase(userId, 'actividad');
    await cargarProgreso();
  }
}
