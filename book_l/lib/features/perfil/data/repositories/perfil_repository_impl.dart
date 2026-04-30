import '../../domain/repositories/perfil_repository.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../../core/services/bookl_service.dart';

/// Implementación del repositorio de perfil.
/// Único punto de contacto con BooklService para esta feature.
class PerfilRepositoryImpl implements PerfilRepository {
  final BooklService _service = BooklService();

  @override
  Usuario? getUsuarioById(int idUsuario) {
    try {
      return _service.usuarios.firstWhere((u) => u.idUsuario == idUsuario);
    } catch (_) {
      return null;
    }
  }

  @override
  void updateUsuario(Usuario usuario) {
    _service.updateUsuario(usuario);
  }

  @override
  int getPublicacionesCount(int idUsuario) {
    return _service.cursos
        .where((c) => c.idUsuarioFk == idUsuario)
        .length;
  }

  @override
  int getFollowersCount(int idUsuario) {
    return _service.getFollowersCount(idUsuario);
  }

  @override
  int getFollowingCount(int idUsuario) {
    return _service.getFollowingCount(idUsuario);
  }

  @override
  bool isFollowing(int idSeguidor, int idSeguido) {
    return _service.isFollowing(idSeguidor, idSeguido);
  }

  @override
  void toggleSeguir(int idSeguidor, int idSeguido) {
    _service.toggleSeguir(idSeguidor, idSeguido);
  }

  @override
  List<Usuario> getSeguidores(int idUsuario) {
    final refs = _service.seguidores
        .where((s) => s['id_seguido'] == idUsuario && s['estado'] == 'activo')
        .map((s) => s['id_seguidor'] as int)
        .toList();
    return _service.usuarios.where((u) => refs.contains(u.idUsuario)).toList();
  }

  @override
  List<Usuario> getSeguidos(int idUsuario) {
    final refs = _service.seguidores
        .where((s) => s['id_seguidor'] == idUsuario && s['estado'] == 'activo')
        .map((s) => s['id_seguido'] as int)
        .toList();
    return _service.usuarios.where((u) => refs.contains(u.idUsuario)).toList();
  }

  @override
  List<dynamic> getLeccionesDeUsuario(int idUsuario) {
    return _service.lecciones
        .where((l) => l.idUsuarioFk == idUsuario)
        .toList();
  }

  @override
  List<dynamic> getCursosDeUsuario(int idUsuario) {
    return _service.cursos
        .where((c) => c.idUsuarioFk == idUsuario)
        .toList();
  }

  @override
  String get currentRole => _service.currentRole;
}
