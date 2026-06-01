import '../../../domain/models/configuracion.dart';

abstract class ConfiguracionRepository {
  Configuracion getConfiguracionByUsuario(int idUsuario);
  Future<void> saveConfiguracion(Configuracion config);
  Future<void> enviarSugerencia(Map<String, dynamic> sugerencia);
}
