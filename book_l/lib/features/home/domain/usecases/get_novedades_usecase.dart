import 'package:flutter/material.dart';
import '../../../../core/services/bookl_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/novedad.dart';

class GetNovedadesUseCase implements UseCase<List<Novedad>, NoParams> {
  @override
  Future<List<Novedad>> call(NoParams params) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final service = BooklService();
    final usuarios = service.usuarios;
    final List<Novedad> todos = [];

    // ── CURSOS ──
    for (final curso in service.cursos) {
      if (curso.createdAt == null) continue;
      final autor = usuarios.where((u) => u.idUsuario == curso.idUsuarioFk).firstOrNull;
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
    for (final leccion in service.lecciones) {
      if (leccion.createdAt == null) continue;
      final autor = usuarios.where((u) => u.idUsuario == leccion.idUsuarioFk).firstOrNull;
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
    for (final capitulo in service.capitulos) {
      if (capitulo.createdAt == null) continue;
      // Capitulo no tiene idUsuario directo → tomamos el de la lección padre
      final leccionPadre = service.lecciones
          .where((l) => l.idLeccion == capitulo.idLeccion)
          .firstOrNull;
      final autor = leccionPadre != null
          ? usuarios.where((u) => u.idUsuario == leccionPadre.idUsuarioFk).firstOrNull
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
}
