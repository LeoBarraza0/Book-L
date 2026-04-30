import '../../../auth/domain/entities/usuario.dart';

/// Interfaz del repositorio de perfil.
/// Define todas las operaciones de datos necesarias para la feature de perfil.
abstract class PerfilRepository {
  /// Obtiene un usuario por su ID. Retorna null si no existe.
  Usuario? getUsuarioById(int idUsuario);

  /// Actualiza los datos de un usuario existente.
  void updateUsuario(Usuario usuario);

  /// Obtiene la cantidad de publicaciones (cursos) del usuario.
  int getPublicacionesCount(int idUsuario);

  /// Obtiene la cantidad de seguidores de un usuario.
  int getFollowersCount(int idUsuario);

  /// Obtiene la cantidad de usuarios que sigue.
  int getFollowingCount(int idUsuario);

  /// Verifica si un usuario sigue a otro.
  bool isFollowing(int idSeguidor, int idSeguido);

  /// Alterna el estado de seguimiento entre dos usuarios.
  void toggleSeguir(int idSeguidor, int idSeguido);

  /// Obtiene la lista de seguidores de un usuario.
  List<Usuario> getSeguidores(int idUsuario);

  /// Obtiene la lista de usuarios que sigue.
  List<Usuario> getSeguidos(int idUsuario);

  /// Obtiene las lecciones creadas por un usuario.
  List<dynamic> getLeccionesDeUsuario(int idUsuario);

  /// Obtiene los cursos creados por un usuario.
  List<dynamic> getCursosDeUsuario(int idUsuario);

  /// Obtiene el rol actual de la sesión.
  String get currentRole;
}
