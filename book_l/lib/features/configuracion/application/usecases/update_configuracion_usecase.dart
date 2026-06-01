import '../../domain/models/configuracion.dart';
import '../ports/out/configuracion_repository.dart';

class UpdateConfiguracionUseCase {
  final ConfiguracionRepository repository;
  UpdateConfiguracionUseCase(this.repository);

  Future<void> call(Configuracion config) =>
      repository.saveConfiguracion(config);
}
