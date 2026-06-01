import '../ports/out/leccion_repository.dart';

class DeleteMaterialEducativoUseCase {
  final LeccionRepository repository;
  DeleteMaterialEducativoUseCase(this.repository);

  void call(int idMaterial) => repository.eliminarMaterial(idMaterial);
}
