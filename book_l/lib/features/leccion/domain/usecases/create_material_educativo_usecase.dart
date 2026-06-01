import '../entities/material_educativo.dart';
import '../repositories/leccion_repository.dart';

class CreateMaterialEducativoUseCase {
  final LeccionRepository repository;
  CreateMaterialEducativoUseCase(this.repository);

  int call(MaterialEducativo material) => repository.agregarMaterial(material);
}
