import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../../../../core/services/bookl_service.dart';

/// Controlador singleton para la feature de Perfil.
/// Orquesta todas las operaciones del perfil delegando al repositorio.
class PerfilController extends ChangeNotifier {
  static final PerfilController _instance = PerfilController._internal();
  factory PerfilController() => _instance;
  PerfilController._internal() {
    // Escuchar cambios en BooklService para reactividad
    BooklService().addListener(_onServiceChanged);
  }

  final PerfilRepository _repo = PerfilRepositoryImpl();

  void _onServiceChanged() {
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // READ — Usuarios
  // ══════════════════════════════════════════════════════════════════════════

  /// Obtiene un usuario por ID. Retorna null si no existe.
  Usuario? getUsuarioById(int idUsuario) => _repo.getUsuarioById(idUsuario);

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE — Perfil
  // ══════════════════════════════════════════════════════════════════════════

  /// Actualiza los datos del usuario y notifica cambios.
  void updateUsuario(Usuario usuario) {
    _repo.updateUsuario(usuario);
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATS — Publicaciones, Seguidores
  // ══════════════════════════════════════════════════════════════════════════

  /// Cantidad de publicaciones (cursos) del usuario.
  int getPublicacionesCount(int idUsuario) =>
      _repo.getPublicacionesCount(idUsuario);

  /// Cantidad de seguidores.
  int getFollowersCount(int idUsuario) => _repo.getFollowersCount(idUsuario);

  /// Cantidad de seguidos.
  int getFollowingCount(int idUsuario) => _repo.getFollowingCount(idUsuario);

  // ══════════════════════════════════════════════════════════════════════════
  // SEGUIMIENTO
  // ══════════════════════════════════════════════════════════════════════════

  /// Verifica si idSeguidor sigue a idSeguido.
  bool isFollowing(int idSeguidor, int idSeguido) =>
      _repo.isFollowing(idSeguidor, idSeguido);

  /// Alterna el estado de seguimiento.
  void toggleSeguir(int idSeguidor, int idSeguido) {
    _repo.toggleSeguir(idSeguidor, idSeguido);
    notifyListeners();
  }

  /// Lista de seguidores del usuario.
  List<Usuario> getSeguidores(int idUsuario) => _repo.getSeguidores(idUsuario);

  /// Lista de usuarios que sigue.
  List<Usuario> getSeguidos(int idUsuario) => _repo.getSeguidos(idUsuario);

  // ══════════════════════════════════════════════════════════════════════════
  // CONTENIDOS
  // ══════════════════════════════════════════════════════════════════════════

  /// Lecciones creadas por el usuario.
  List<dynamic> getLeccionesDeUsuario(int idUsuario) =>
      _repo.getLeccionesDeUsuario(idUsuario);

  /// Cursos creados por el usuario.
  List<dynamic> getCursosDeUsuario(int idUsuario) =>
      _repo.getCursosDeUsuario(idUsuario);

  // ══════════════════════════════════════════════════════════════════════════
  // SESSION
  // ══════════════════════════════════════════════════════════════════════════

  /// Rol actual de la sesión.
  String get currentRole => _repo.currentRole;

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton — no destruir para mantener el estado
  }
}
