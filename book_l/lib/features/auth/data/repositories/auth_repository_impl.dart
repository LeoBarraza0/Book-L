import '../../../../core/services/bookl_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/dto/usuario_dto.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';

// Adaptador secundario — implementa el contrato AuthRepository usando
// BooklService (JSON en memoria) + AppSession (SharedPreferences).
//
// Cuando se migre a API: reemplazar el cuerpo de cada método para llamar
// a DioClient. La interfaz AuthRepository no cambia.
class AuthRepositoryImpl implements AuthRepository {
  final BooklService _service;
  final AppSession _session;

  AuthRepositoryImpl(this._service, this._session);

  // ── Login ──────────────────────────────────────────────────────────────────
  @override
  Future<Usuario?> login(String correo, String contrasena) async {
    UsuarioDto? found;
    for (final u in _service.usuariosDto) {
      if (u.correo.toLowerCase() == correo.trim().toLowerCase() &&
          u.contrasena == contrasena &&
          u.activo) {
        found = u;
        break;
      }
    }

    if (found == null) return null; // credenciales incorrectas

    final usuario = found.toEntity();

    await _session.guardarSesion(
      token: 'local_${found.idUsuario}', // token simulado para JSON local
      usuarioId: usuario.idUsuario,
      nombreCompleto: usuario.nombreCompleto,
      rol: usuario.rol,
      programa: usuario.programa,
    );

    return usuario;
  }

  // ── Registro ───────────────────────────────────────────────────────────────
  @override
  Future<Usuario> registrar({
    required String nombreCompleto,
    required String correo,
    required String contrasena,
    required String rol,
    String? programa,
  }) async {
    // Verificar que el correo no exista
    final existe = _service.usuariosDto.any(
      (u) => u.correo.toLowerCase() == correo.trim().toLowerCase(),
    );
    if (existe) throw Exception('El correo ya está registrado');

    final nuevoId = _service.nextUsuarioId();
    final dto = UsuarioDto(
      idUsuario: nuevoId,
      nombreCompleto: nombreCompleto.trim(),
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
      rol: rol,
      programa: programa,
      activo: true,
      avatarUrl: null,
    );

    // Persistir en memoria (BooklService)
    _service.usuariosDto.add(dto);
    final usuario = dto.toEntity();
    _service.usuarios.add(usuario);

    // Guardar sesión automáticamente al registrarse
    await _session.guardarSesion(
      token: 'local_$nuevoId',
      usuarioId: nuevoId,
      nombreCompleto: usuario.nombreCompleto,
      rol: usuario.rol,
      programa: usuario.programa,
    );

    return usuario;
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  @override
  Future<void> logout() => _session.cerrarSesion();
}
