import 'package:book_l/features/discusion/domain/models/discusion.dart';
import 'package:book_l/features/discusion/domain/models/comentario.dart';
import 'package:book_l/features/discusion/application/ports/out/discusion_repository.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/discusion/infrastructure/adapters/out/dtos/comentario_dto.dart';
import 'package:flutter/foundation.dart';

class DiscusionRepositoryImpl implements DiscusionRepository {
  final BooklService _service = BooklService();

  @override
  Discusion obtenerOCrearDiscusion({int? idCurso, int? idLeccion}) {
    if (SupabaseClientHelper.isConfigured) {
      final query = SupabaseClientHelper.client.from('tbl_discusion').select();
      final q = idCurso != null ? query.eq('id_cursofk', idCurso) : query.eq('id_leccionfk', idLeccion!);
      q.maybeSingle().then((res) {
        if (res == null) {
          SupabaseClientHelper.client.from('tbl_discusion').insert({
            'id_cursofk': idCurso,
            'id_leccionfk': idLeccion,
          }).select().single().then((insRes) {
            final disc = Discusion(
              idDiscusion: insRes['id_discusion'],
              idCursoFk: insRes['id_cursofk'],
              idLeccionFk: insRes['id_leccionfk'],
            );
            _service.addDiscusion(disc);
          }).catchError((e) {
            if (kDebugMode) print('Error crearDiscusion Supabase: $e');
          });
        }
      }).catchError((e) {
        if (kDebugMode) print('Error obtenerDiscusion Supabase: $e');
      });
    }
    
    // Buscar discusión existente
    final existing = _service.discusiones.firstWhere(
      (d) =>
          (idCurso != null && d.idCursoFk == idCurso) ||
          (idLeccion != null && d.idLeccionFk == idLeccion),
      orElse: () {
        // Crear nueva discusión localmente
        final newId = (_service.discusiones.isEmpty)
            ? 1
            : _service.discusiones
                    .map((d) => d.idDiscusion)
                    .reduce((a, b) => a > b ? a : b) +
                1;
        final nueva = Discusion(
          idDiscusion: newId,
          idCursoFk: idCurso,
          idLeccionFk: idLeccion,
        );
        _service.addDiscusion(nueva);
        return nueva;
      },
    );
    return existing;
  }

  @override
  List<Comentario> getComentariosRaiz(int idDiscusion) {
    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client
          .from('tbl_comentario')
          .select()
          .eq('id_discusionfk', idDiscusion)
          .isFilter('id_padre', null)
          .then((res) {
        final list = res.map((e) => ComentarioDto.fromJson(e)).toList();
        for (var c in list) {
          if (!_service.comentarios.any((lc) => lc.idComentario == c.idComentario)) {
            _service.addComentario(c);
          }
        }
      }).catchError((e) {
        if (kDebugMode) print('Error getComentariosRaiz Supabase: $e');
      });
    }

    return _service.comentarios
        .where((c) => c.idDiscusionFk == idDiscusion && c.idPadre == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  List<Comentario> getRespuestas(int idComentarioPadre) {
    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client
          .from('tbl_comentario')
          .select()
          .eq('id_padre', idComentarioPadre)
          .then((res) {
        final list = res.map((e) => ComentarioDto.fromJson(e)).toList();
        for (var c in list) {
          if (!_service.comentarios.any((lc) => lc.idComentario == c.idComentario)) {
            _service.addComentario(c);
          }
        }
      }).catchError((e) {
        if (kDebugMode) print('Error getRespuestas Supabase: $e');
      });
    }
    
    return _service.comentarios
        .where((c) => c.idPadre == idComentarioPadre)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<Comentario> agregarComentario({
    required int idDiscusion,
    required int idUsuario,
    required String contenido,
    int? idPadre,
  }) async {
    if (SupabaseClientHelper.isConfigured) {
      try {
        final res = await SupabaseClientHelper.client.from('tbl_comentario').insert({
          'id_discusionfk': idDiscusion,
          'id_usuariofk': idUsuario,
          'contenido': contenido,
          'id_padre': idPadre,
        }).select().single();
        
        final ins = ComentarioDto.fromJson(res);
        final idx = _service.comentarios.indexWhere((c) => c.contenido == contenido && c.idUsuarioFk == idUsuario && c.idDiscusionFk == idDiscusion);
        if (idx != -1) {
          _service.comentarios[idx] = ins;
        } else {
          _service.addComentario(ins);
        }

        // --- Enviar Notificación ---
        try {
          final disc = _service.discusiones.firstWhere((d) => d.idDiscusion == idDiscusion);
          int? idDestino;
          String tipoNotif = 'comment';
          String msj = 'Han comentado en tu contenido.';

          if (idPadre != null) {
            final padre = _service.comentarios.firstWhere((c) => c.idComentario == idPadre);
            idDestino = padre.idUsuarioFk;
            tipoNotif = 'reply';
            msj = 'Alguien ha respondido a tu comentario.';
          } else {
            if (disc.idCursoFk != null) {
              final curso = _service.cursos.firstWhere((c) => c.idCurso == disc.idCursoFk);
              idDestino = curso.idUsuarioFk;
              msj = 'Han comentado en tu curso.';
            } else if (disc.idLeccionFk != null) {
              final leccion = _service.lecciones.firstWhere((l) => l.idLeccion == disc.idLeccionFk);
              idDestino = leccion.idUsuarioFk;
              msj = 'Han comentado en tu lección.';
            }
          }

          if (idDestino != null && idDestino != idUsuario) {
            _service.generarNotificacion(
              idUsuarioDestino: idDestino,
              tipo: tipoNotif,
              mensaje: msj,
              idReferencia: idUsuario,
              idCursoFk: disc.idCursoFk,
              idLeccionFk: disc.idLeccionFk,
              idComentarioFk: ins.idComentario,
            );
          }
        } catch (_) {}

        return ins;
      } catch (e) {
        if (kDebugMode) print('Error agregarComentario Supabase: $e');
      }
    }

    final newId = (_service.comentarios.isEmpty)
        ? 1
        : _service.comentarios
                .map((c) => c.idComentario)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final nuevo = Comentario(
      idComentario: newId,
      idDiscusionFk: idDiscusion,
      idUsuarioFk: idUsuario,
      contenido: contenido,
      idPadre: idPadre,
      createdAt: DateTime.now(),
    );
    _service.addComentario(nuevo);
    return nuevo;
  }

  /// Todos los comentarios, para inicializar conteos de likes
  List<Comentario> getAllComentarios() {
    if (SupabaseClientHelper.isConfigured) {
      SupabaseClientHelper.client.from('tbl_comentario').select().then((res) {
        final list = res.map((e) => ComentarioDto.fromJson(e)).toList();
        for (var c in list) {
          if (!_service.comentarios.any((lc) => lc.idComentario == c.idComentario)) {
            _service.addComentario(c);
          }
        }
      }).catchError((e) {
        if (kDebugMode) print('Error getAllComentarios Supabase: $e');
      });
    }
    return List.unmodifiable(_service.comentarios);
  }

  @override
  dynamic getUserSync(int idUsuario) {
    try {
      return _service.usuarios.firstWhere((u) => u.idUsuario == idUsuario);
    } catch (_) {
      return null;
    }
  }
}
