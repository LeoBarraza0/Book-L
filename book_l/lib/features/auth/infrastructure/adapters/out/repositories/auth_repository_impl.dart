import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/auth/infrastructure/adapters/out/dtos/usuario_dto.dart';
import 'package:book_l/features/auth/domain/models/usuario.dart';
import 'package:book_l/features/auth/application/ports/out/auth_repository.dart';
import 'package:flutter/foundation.dart';

// Adaptador secundario — implementa el contrato AuthRepository usando
// Supabase (PostgreSQL) + BooklService + AppSession (SharedPreferences).
class AuthRepositoryImpl implements AuthRepository {
  final BooklService _service;
  final AppSession _session;

  AuthRepositoryImpl(this._service, this._session);

  // ── Login ──────────────────────────────────────────────────────────────────
  @override
  Future<Usuario?> login(String correo, String contrasena) async {
    UsuarioDto? found;

    if (SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;
        final res = await client
            .from('tbl_usuario')
            .select()
            .eq('correo', correo.trim().toLowerCase())
            .eq('contrasena', contrasena)
            .eq('activo', true)
            .maybeSingle();

        if (res != null) {
          found = UsuarioDto.fromJson(res);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error al iniciar sesión en Supabase: $e");
        }
      }
    }

    // Fallback: Si no está configurado Supabase o falló la red, buscar localmente
    if (found == null) {
      for (final u in _service.usuariosDto) {
        if (u.correo.toLowerCase() == correo.trim().toLowerCase() &&
            u.contrasena == contrasena &&
            u.activo) {
          found = u;
          break;
        }
      }
    }

    if (found == null) return null; // credenciales incorrectas

    // Sincronizar en el servicio local si el usuario vino de Supabase y no estaba en la cache
    if (!_service.usuariosDto.any((u) => u.idUsuario == found!.idUsuario)) {
      _service.usuariosDto.add(found);
      _service.usuarios.add(found.toEntity());
    }

    final usuario = found.toEntity();
    
    // Actualizar el rol en el servicio global
    _service.setRole(usuario.rol);

    await _session.guardarSesion(
      token: 'supabase_${found.idUsuario}',
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
    int? celular,
    int? semestre,
    DateTime? nacimiento,
    String? preferencias,
    String? avatarUrl,
    String? descripcion,
  }) async {
    UsuarioDto? dto;

    if (SupabaseClientHelper.isConfigured) {
      try {
        final client = SupabaseClientHelper.client;

        // Verificar si el correo ya existe en Supabase
        final existeRes = await client
            .from('tbl_usuario')
            .select('idusuario')
            .eq('correo', correo.trim().toLowerCase())
            .maybeSingle();

        if (existeRes != null) {
          throw Exception('El correo ya está registrado');
        }

        // Generar un username automático a partir del correo
        final baseUsername = correo.trim().toLowerCase().split('@').first;
        final randomSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
        final generatedUsername = '${baseUsername}_$randomSuffix';

        // Insertar en Supabase. El id se autogenera mediante SERIAL
        final insertRes = await client.from('tbl_usuario').insert(Map<String, dynamic>.from({
          'nombrecompleto': nombreCompleto.trim(),
          'correo': correo.trim().toLowerCase(),
          'contrasena': contrasena,
          'username': generatedUsername,
          'rol': rol,
          if (programa != null) 'programa': programa,
          if (celular != null) 'celular': celular,
          if (semestre != null) 'semestre': semestre,
          if (nacimiento != null) 'nacimiento': nacimiento.toIso8601String().split('T').first,
          if (preferencias != null) 'preferencias': preferencias,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (descripcion != null) 'descripcion': descripcion,
          'activo': true,
        })).select().single();

        dto = UsuarioDto.fromJson(insertRes);

        // Sincronizar en el servicio local
        if (!_service.usuariosDto.any((u) => u.idUsuario == dto!.idUsuario)) {
          _service.usuariosDto.add(dto);
          _service.usuarios.add(dto.toEntity());
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error al registrar en Supabase: $e");
        }
        if (e.toString().contains('ya está registrado')) {
          rethrow;
        }
      }
    }

    // Fallback: Si no está configurado o falló la red
    if (dto == null) {
      final existe = _service.usuariosDto.any(
        (u) => u.correo.toLowerCase() == correo.trim().toLowerCase(),
      );
      if (existe) throw Exception('El correo ya está registrado');

      final nuevoId = _service.nextUsuarioId();
      final baseUsername = correo.trim().toLowerCase().split('@').first;
      final randomSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
      final generatedUsername = '${baseUsername}_$randomSuffix';

      dto = UsuarioDto(
        idUsuario: nuevoId,
        nombreCompleto: nombreCompleto.trim(),
        correo: correo.trim().toLowerCase(),
        contrasena: contrasena,
        username: generatedUsername,
        rol: rol,
        programa: programa,
        celular: celular,
        semestre: semestre,
        nacimiento: nacimiento,
        preferencias: preferencias,
        descripcion: descripcion,
        activo: true,
        avatarUrl: avatarUrl,
      );

      _service.usuariosDto.add(dto);
      _service.usuarios.add(dto.toEntity());
      _service.guardarDatos();
    }

    final usuario = dto.toEntity();
    
    // Actualizar el rol en el servicio global
    _service.setRole(usuario.rol);

    // Guardar sesión automáticamente al registrarse
    await _session.guardarSesion(
      token: 'supabase_${dto.idUsuario}',
      usuarioId: dto.idUsuario,
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