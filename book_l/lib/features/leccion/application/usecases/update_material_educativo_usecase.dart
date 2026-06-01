import '../../domain/models/material_educativo.dart';
import '../ports/out/leccion_repository.dart';

class UpdateMaterialEducativoUseCase {
  final LeccionRepository repository;
  UpdateMaterialEducativoUseCase(this.repository);

  void call(MaterialEducativo material) =>
      repository.actualizarMaterial(material);
}
