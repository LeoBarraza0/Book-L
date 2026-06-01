import '../../domain/models/material_educativo.dart';
import '../ports/out/leccion_repository.dart';

class CreateMaterialEducativoUseCase {
  final LeccionRepository repository;
  CreateMaterialEducativoUseCase(this.repository);

  int call(MaterialEducativo material) => repository.agregarMaterial(material);
}
