import '../entities/configuracion.dart';
import '../repositories/configuracion_repository.dart';

class UpdateConfiguracionUseCase {
  final ConfiguracionRepository repository;
  UpdateConfiguracionUseCase(this.repository);

  Future<void> call(Configuracion config) => repository.saveConfiguracion(config);
}
