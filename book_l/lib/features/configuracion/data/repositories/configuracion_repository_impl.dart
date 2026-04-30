import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/configuracion.dart';
import '../../domain/repositories/configuracion_repository.dart';

class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  final BooklService _service = BooklService();

  @override
  Configuracion getConfiguracionByUsuario(int idUsuario) {
    try {
      return _service.configuraciones.firstWhere((c) => c.idUsuario == idUsuario);
    } catch (e) {
      return Configuracion(
        idConfig: _service.generateId(),
        idUsuario: idUsuario,
        temaOscuro: false,
        idioma: 'es',
        notificacionesPush: true,
        notificacionesEmail: true,
        notificacionesRacha: true,
        tamanoFuente: 'normal',
        reproduccionAuto: true,
        perfilPublico: true,
      );
    }
  }

  @override
  Future<void> saveConfiguracion(Configuracion config) async {
    _service.saveConfiguracion(config);
  }

  @override
  Future<void> enviarSugerencia(Map<String, dynamic> sugerencia) async {
    // Agregamos el ID generado aquí para mantener la lógica de persistencia encapsulada
    sugerencia['id_sugerencia'] = _service.generateId();
    _service.saveSugerencia(sugerencia);
  }
}
