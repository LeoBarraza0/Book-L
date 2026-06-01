import 'package:flutter/material.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/features/configuracion/domain/models/configuracion.dart';
import 'package:book_l/features/configuracion/infrastructure/adapters/out/repositories/configuracion_repository_impl.dart';
import 'package:book_l/features/configuracion/application/usecases/update_configuracion_usecase.dart';

class ConfiguracionController extends ChangeNotifier {
  final ConfiguracionRepositoryImpl _repository;
  final UpdateConfiguracionUseCase _updateConfiguracionUseCase;

  Configuracion? config;
  bool isLoading = true;

  ConfiguracionController()
      : _repository = ConfiguracionRepositoryImpl(),
        _updateConfiguracionUseCase =
            UpdateConfiguracionUseCase(ConfiguracionRepositoryImpl()) {
    _loadConfig();
  }

  void _loadConfig() {
    final userId = AppSession().usuarioId;
    if (userId != null) {
      config = _repository.getConfiguracionByUsuario(userId);
    }
    isLoading = false;
    notifyListeners();
  }

  void updateTemaOscuro(bool value) {
    if (config == null) return;
    config = config!.copyWith(temaOscuro: value);
    _save();
    // También actualizar en AppSession
    AppSession().guardarPreferencias(temaOscuro: value);
  }

  void updateReproduccionAuto(bool value) {
    if (config == null) return;
    config = config!.copyWith(reproduccionAuto: value);
    _save();
  }

  void updateTamanoFuente(String value) {
    if (config == null) return;
    config = config!.copyWith(tamanoFuente: value);
    _save();
    // También actualizar en AppSession para que aplique global
    AppSession().guardarPreferencias(tamanoFuente: value);
  }

  Future<void> cerrarSesion() async {
    await AppSession().cerrarSesion();
  }

  void _save() {
    if (config != null) {
      _updateConfiguracionUseCase(config!);
      notifyListeners();
    }
  }

  Future<void> enviarSugerencia(String asunto, String problema) async {
    final userId = AppSession().usuarioId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final sugerencia = {
      'id_usuario': userId,
      'asunto': asunto,
      'problema': problema,
      'fecha': DateTime.now().toIso8601String(),
    };

    // Delega al repositorio para persistir (cumple Clean Architecture)
    await _repository.enviarSugerencia(sugerencia);
  }
}
