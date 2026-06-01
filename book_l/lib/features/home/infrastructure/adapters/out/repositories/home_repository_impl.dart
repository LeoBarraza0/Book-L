import 'package:flutter/material.dart';
import 'package:book_l/features/home/application/ports/out/home_repository.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/home/domain/models/novedad.dart';

class HomeRepositoryImpl implements HomeRepository {
  final BooklService _service = BooklService();

  @override
  List<Leccion> getLeccionesActivas() {
    return _service.lecciones.where((l) => l.estado == 'activa').toList();
  }

  @override
  List<Curso> getCursosPublicados() {
    return _service.cursos.where((c) => c.estado == 'Publicado').toList();
  }

  @override
  Future<List<Novedad>> getNovedades() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final usuarios = _service.usuarios;
    final List<Novedad> todos = [];

    // ── CURSOS ──
    for (final curso in _service.cursos) {
      if (curso.createdAt == null) continue;
      final autor =
          usuarios.where((u) => u.idUsuario == curso.idUsuarioFk).firstOrNull;
      todos.add(Novedad(
        idEntidad: curso.idCurso,
        titulo: curso.nombre,
        tipo: 'Curso',
        autorNombre: autor?.nombreCompleto ?? 'Desconocido',
        fechaPublicacion: curso.createdAt!,
        colorTema: const Color(0xFFFF606F),
      ));
    }

    // ── LECCIONES ──
    for (final leccion in _service.lecciones) {
      if (leccion.createdAt == null) continue;
      final autor =
          usuarios.where((u) => u.idUsuario == leccion.idUsuarioFk).firstOrNull;
      todos.add(Novedad(
        idEntidad: leccion.idLeccion,
        titulo: leccion.nombre,
        tipo: 'Lección',
        autorNombre: autor?.nombreCompleto ?? 'Desconocido',
        fechaPublicacion: leccion.createdAt!,
        colorTema: const Color(0xFF5AB639),
      ));
    }

    // ── CAPÍTULOS ──
    for (final capitulo in _service.capitulos) {
      if (capitulo.createdAt == null) continue;
      // Capitulo no tiene idUsuario directo → tomamos el de la lección padre
      final leccionPadre = _service.lecciones
          .where((l) => l.idLeccion == capitulo.idLeccion)
          .firstOrNull;
      final autor = leccionPadre != null
          ? usuarios
              .where((u) => u.idUsuario == leccionPadre.idUsuarioFk)
              .firstOrNull
          : null;
      todos.add(Novedad(
        idEntidad: capitulo.idCapitulo,
        titulo: capitulo.nombre,
        tipo: 'Capítulo',
        autorNombre: autor?.nombreCompleto ?? 'Desconocido',
        fechaPublicacion: capitulo.createdAt!,
        colorTema: const Color(0xFFFFB800),
      ));
    }

    // Ordenamos descendientemente y tomamos los 2 más recientes
    todos.sort((a, b) => b.fechaPublicacion.compareTo(a.fechaPublicacion));
    return todos.take(2).toList();
  }

  @override
  Map<String, dynamic>? getRacha(int userId) {
    return _service.getRacha(userId);
  }
}
