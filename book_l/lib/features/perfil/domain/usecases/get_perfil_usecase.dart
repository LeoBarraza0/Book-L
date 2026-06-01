import '../../../auth/domain/entities/usuario.dart';
import '../repositories/perfil_repository.dart';

class GetPerfilUseCase {
  final PerfilRepository repository;
  GetPerfilUseCase(this.repository);

  Usuario? call(int idUsuario) => repository.getUsuarioById(idUsuario);
}
