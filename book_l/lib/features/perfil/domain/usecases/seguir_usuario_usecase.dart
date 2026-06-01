import '../../../../core/usecase/usecase.dart';
import '../repositories/perfil_repository.dart';
import 'get_perfil_usecase.dart';

class SeguirUsuarioParams {
  final int idSeguidor;
  final int idSeguido;
  SeguirUsuarioParams({required this.idSeguidor, required this.idSeguido});
}

/// Caso de uso: Seguir Usuario.
/// Relación `<<extend>>`: extiende la visualización del perfil.
class SeguirUsuarioUseCase implements UMLExtend<GetPerfilUseCase> {
  final PerfilRepository repository;

  @override
  final GetPerfilUseCase baseUseCase;

  SeguirUsuarioUseCase(this.repository, this.baseUseCase);

  @override
  bool shouldExtend(dynamic context) => context != null;

  void call(SeguirUsuarioParams params) {
    repository.toggleSeguir(params.idSeguidor, params.idSeguido);
  }
}
