import '../entities/material_educativo.dart';
import '../repositories/leccion_repository.dart';

class UpdateMaterialEducativoUseCase {
  final LeccionRepository repository;
  UpdateMaterialEducativoUseCase(this.repository);

  void call(MaterialEducativo material) => repository.actualizarMaterial(material);
}
