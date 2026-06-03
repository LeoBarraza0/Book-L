import 'package:book_l/features/guardado/application/ports/out/guardado_repository.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';
import 'package:book_l/core/infrastructure/services/supabase_client.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de guardados (favoritos).
class GuardadoRepositoryImpl implements GuardadoRepository {
  final BooklService _service = BooklService();
  final AppSession _session = AppSession();

  @override
  List<Leccion> getSavedLecciones() {
    final savedIds = _session.savedLecciones.value;
    return _service.lecciones
        .where((l) => savedIds.contains(l.idLeccion))
        .toList();
  }

  @override
  List<Curso> getSavedCursos() {
    final savedIds = _session.savedCursos.value;
    return _service.cursos.where((c) => savedIds.contains(c.idCurso)).toList();
  }

  @override
  void toggleSavedLeccion(int idLeccion) {
    final isSaved = _session.savedLecciones.value.contains(idLeccion);
    _session.toggleSavedLeccion(idLeccion);
    
    final userId = _session.usuarioId;
    if (userId != null && SupabaseClientHelper.isConfigured) {
      if (!isSaved) {
        // We are saving it now
        SupabaseClientHelper.client.from('tbl_guardado_leccion').insert({
          'idusuario': userId,
          'idleccion': idLeccion,
        }).catchError((e) {
          if (kDebugMode) print('Error guardar leccion Supabase: $e');
        });
      } else {
        // We are unsaving it
        SupabaseClientHelper.client
            .from('tbl_guardado_leccion')
            .delete()
            .eq('idusuario', userId)
            .eq('idleccion', idLeccion)
            .catchError((e) {
          if (kDebugMode) print('Error desguardar leccion Supabase: $e');
        });
      }
    }
  }

  @override
  void toggleSavedCurso(int idCurso) {
    final isSaved = _session.savedCursos.value.contains(idCurso);
    _session.toggleSavedCurso(idCurso);
    
    final userId = _session.usuarioId;
    if (userId != null && SupabaseClientHelper.isConfigured) {
      if (!isSaved) {
        // We are saving it now
        SupabaseClientHelper.client.from('tbl_guardado_curso').insert({
          'idusuario': userId,
          'idcurso': idCurso,
        }).catchError((e) {
          if (kDebugMode) print('Error guardar curso Supabase: $e');
        });
      } else {
        // We are unsaving it
        SupabaseClientHelper.client
            .from('tbl_guardado_curso')
            .delete()
            .eq('idusuario', userId)
            .eq('idcurso', idCurso)
            .catchError((e) {
          if (kDebugMode) print('Error desguardar curso Supabase: $e');
        });
      }
    }
  }

  @override
  bool isLeccionSaved(int idLeccion) {
    return _session.savedLecciones.value.contains(idLeccion);
  }

  @override
  bool isCursoSaved(int idCurso) {
    return _session.savedCursos.value.contains(idCurso);
  }
}
