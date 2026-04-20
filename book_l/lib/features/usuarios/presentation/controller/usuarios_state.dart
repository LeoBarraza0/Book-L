import '../../domain/entities/usuarios.dart';

/// Estados posibles para la pantalla de Usuarios.
abstract class UsuariosState {}

/// Estado inicial antes de cualquier carga.
class UsuariosInitial extends UsuariosState {}

/// Cargando datos.
class UsuariosLoading extends UsuariosState {}

/// Datos cargados correctamente.
class UsuariosLoaded extends UsuariosState {
  final List<Usuario> usuarios;
  UsuariosLoaded(this.usuarios);
}

/// Error durante la carga o alguna operación.
class UsuariosError extends UsuariosState {
  final String message;
  UsuariosError(this.message);
}
