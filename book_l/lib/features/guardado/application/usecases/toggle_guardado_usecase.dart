import '../../../../core/usecase/usecase.dart';
import '../ports/out/guardado_repository.dart';
import 'get_guardados_usecase.dart';

enum TipoGuardado { leccion, curso }

class ToggleGuardadoParams {
  final int id;
  final TipoGuardado tipo;
  ToggleGuardadoParams({required this.id, required this.tipo});
}

/// Caso de uso: Guardar Contenido.
/// Relación `<<extend>>`: extiende la visualización de guardados o detalles de lecciones/cursos.
class ToggleGuardadoUseCase implements UMLExtend<GetGuardadosUseCase> {
  final GuardadoRepository repository;

  @override
  final GetGuardadosUseCase baseUseCase;

  ToggleGuardadoUseCase(this.repository, this.baseUseCase);

  @override
  bool shouldExtend(dynamic context) {
    return context != null;
  }

  void call(ToggleGuardadoParams params) {
    switch (params.tipo) {
      case TipoGuardado.leccion:
        repository.toggleSavedLeccion(params.id);
        break;
      case TipoGuardado.curso:
        repository.toggleSavedCurso(params.id);
        break;
    }
  }
}
