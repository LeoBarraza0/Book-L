import '../entities/configuracion.dart';

abstract class ConfiguracionRepository {
  Configuracion getConfiguracionByUsuario(int idUsuario);
  Future<void> saveConfiguracion(Configuracion config);
}
