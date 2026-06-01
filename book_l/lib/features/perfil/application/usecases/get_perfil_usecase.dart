import '../../../auth/domain/models/usuario.dart';
import '../ports/out/perfil_repository.dart';

class GetPerfilUseCase {
  final PerfilRepository repository;
  GetPerfilUseCase(this.repository);

  Usuario? call(int idUsuario) => repository.getUsuarioById(idUsuario);
}
