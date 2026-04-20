import 'package:flutter/material.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/configuracion.dart';
import '../../data/repositories/configuracion_repository_impl.dart';

class ConfiguracionController extends ChangeNotifier {
  final ConfiguracionRepositoryImpl _repository = ConfiguracionRepositoryImpl();
  
  Configuracion? config;
  bool isLoading = true;

  ConfiguracionController() {
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
      _repository.saveConfiguracion(config!);
      notifyListeners();
    }
  }
}
