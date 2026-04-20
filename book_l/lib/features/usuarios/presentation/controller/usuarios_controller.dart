import 'package:flutter/foundation.dart';
import '../../domain/entities/usuarios.dart';
import '../../domain/usecases/get_usuarios_usecase.dart';
import './usuarios_state.dart';

/// Adaptador primario (Controller) de la feature Usuarios.
///
/// Extiende [ChangeNotifier] para poder ser consumido con
/// [ListenableBuilder] o [AnimatedBuilder] sin dependencias externas.
///
/// Migración futura: cuando se integre Riverpod/Bloc, este controller
/// puede transformarse en un Notifier/Cubit sin cambiar los use cases.
class UsuariosController extends ChangeNotifier {
  final GetUsuariosUseCase _getUsuarios;
  final AddUsuarioUseCase _addUsuario;
  final UpdateUsuarioUseCase _updateUsuario;
  final DeleteUsuarioUseCase _deleteUsuario;

  UsuariosState _state = UsuariosInitial();
  UsuariosState get state => _state;

  UsuariosController({
    required GetUsuariosUseCase getUsuarios,
    required AddUsuarioUseCase addUsuario,
    required UpdateUsuarioUseCase updateUsuario,
    required DeleteUsuarioUseCase deleteUsuario,
  })  : _getUsuarios = getUsuarios,
        _addUsuario = addUsuario,
        _updateUsuario = updateUsuario,
        _deleteUsuario = deleteUsuario;

  void _emit(UsuariosState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Carga los usuarios desde el repositorio.
  Future<void> cargarUsuarios() async {
    _emit(UsuariosLoading());
    try {
      final usuarios = await _getUsuarios();
      _emit(UsuariosLoaded(usuarios));
    } catch (e) {
      _emit(UsuariosError('Error al cargar usuarios: $e'));
    }
  }

  /// Añade un nuevo [usuario] y actualiza el estado.
  Future<void> agregarUsuario(Usuario usuario) async {
    try {
      final lista = await _addUsuario(usuario);
      _emit(UsuariosLoaded(lista));
    } catch (e) {
      _emit(UsuariosError('Error al agregar usuario: $e'));
    }
  }

  /// Actualiza un [usuario] existente y actualiza el estado.
  Future<void> editarUsuario(Usuario usuario) async {
    try {
      final lista = await _updateUsuario(usuario);
      _emit(UsuariosLoaded(lista));
    } catch (e) {
      _emit(UsuariosError('Error al editar usuario: $e'));
    }
  }

  /// Elimina el usuario con [idUsuario] y actualiza el estado.
  Future<void> eliminarUsuario(int idUsuario) async {
    try {
      final lista = await _deleteUsuario(idUsuario);
      _emit(UsuariosLoaded(lista));
    } catch (e) {
      _emit(UsuariosError('Error al eliminar usuario: $e'));
    }
  }
}
