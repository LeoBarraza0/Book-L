import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../repositories/perfil_repository.dart';
import 'get_perfil_usecase.dart';

/// Caso de uso: Actualizar Perfil.
/// Relación `<<extend>>`: extiende la visualización del perfil.
class UpdatePerfilUseCase implements UMLExtend<GetPerfilUseCase> {
  final PerfilRepository repository;

  @override
  final GetPerfilUseCase baseUseCase;

  UpdatePerfilUseCase(this.repository, this.baseUseCase);

  @override
  bool shouldExtend(dynamic context) => context != null;

  void call(Usuario usuario) => repository.updateUsuario(usuario);
}
