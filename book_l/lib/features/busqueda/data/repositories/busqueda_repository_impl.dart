import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/busqueda_repository.dart';

// ── Normalización: elimina tildes y pasa a minúsculas ────────────────────────
String _normalizar(String texto) {
  const Map<String, String> reemplazos = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'Á': 'a',
    'É': 'e',
    'Í': 'i',
    'Ó': 'o',
    'Ú': 'u',
    'ñ': 'n',
    'Ñ': 'n',
    'ü': 'u',
    'Ü': 'u',
  };
  return texto.toLowerCase().replaceAllMapped(
        RegExp('[áéíóúÁÉÍÓÚñÑüÜ]'),
        (m) => reemplazos[m.group(0)!] ?? m.group(0)!,
      );
}

// ── Paleta de colores para tarjetas ─────────────────────────────────────────
const List<Color> _paleta = [
  Color(0xFF9DE596),
  Color(0xFF96D4DB),
  Color(0xFF888BC6),
  Color(0xFFFA8E9E),
  Color(0xFFF6CE74),
  Color(0xFFB5D3F2),
];
Color _colorPorId(int id) => _paleta[id % _paleta.length];

// ── Repositorio ──────────────────────────────────────────────────────────────
class BusquedaRepositoryImpl implements BusquedaRepository {
  // ── Búsqueda principal ────────────────────────────────────────────────────
  @override
  Future<List<ResultadoBusqueda>> buscar(
    String query, {
    String filtro = 'Todos',
  }) async {
    if (query.trim().isEmpty) return [];

    final q = _normalizar(query);
    final resultados = <ResultadoBusqueda>[];
    final svc = BooklService();

    // ── Cursos ───────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Cursos') {
      for (final c in svc.cursos) {
        if (_normalizar(c.nombre).contains(q)) {
          final imagenUrl = c.imagenUrl ?? _extraerImagenUrl(c.contenido);
          resultados.add(ResultadoBusqueda(
            id: c.idCurso,
            tipo: 'Curso',
            titulo: c.nombre,
            subtitulo: _autorDeCurso(svc, c.idUsuarioFk),
            imagenUrl: imagenUrl,
            calificacion: c.rating > 0 ? c.rating.toStringAsFixed(1) : '0.0',
            colorTarjeta: _colorPorId(c.idCurso),
            inscripciones: c.estudiantes,
          ));
        }
      }
    }

    // ── Lecciones ────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Lecciones') {
      for (final l in svc.lecciones) {
        if (_normalizar(l.nombre).contains(q)) {
          final imagenUrl = l.imagenUrl ?? _extraerImagenUrl(l.contenido);
          resultados.add(ResultadoBusqueda(
            id: l.idLeccion,
            tipo: 'Lección',
            titulo: l.nombre,
            subtitulo: _cursoDeLeccion(svc, l.idLeccion),
            imagenUrl: imagenUrl,
            calificacion: l.rating > 0 ? l.rating.toStringAsFixed(1) : '0.0',
            colorTarjeta: _colorPorId(l.idLeccion + 3),
          ));
        }
      }
    }

    // ── Autores ──────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Autores') {
      for (final u in svc.usuarios) {
        final rol = u.rol.toLowerCase();
        if (rol == 'administrador') continue;

        if (_normalizar(u.nombreCompleto).contains(q)) {
          resultados.add(ResultadoBusqueda(
            id: u.idUsuario,
            tipo: 'Autor',
            titulo: u.nombreCompleto,
            subtitulo: u.programa,
            imagenUrl: u.avatarUrl,
            username: u.username,
            avatarUrl: u.avatarUrl,
            colorTarjeta: _colorPorId(u.idUsuario + 5),
          ));
        }
      }
    }

    // ── Ordenar por relevancia (título exacto primero) ───────────────────────
    resultados.sort((a, b) {
      final aExacto = _normalizar(a.titulo).startsWith(q) ? 0 : 1;
      final bExacto = _normalizar(b.titulo).startsWith(q) ? 0 : 1;
      return aExacto.compareTo(bExacto);
    });

    return resultados;
  }

  // ── Sugerencias mientras el usuario escribe (máx. 6) ─────────────────────
  @override
  Future<List<String>> sugerencias(String query) async {
    if (query.trim().length < 2) return [];

    final q = _normalizar(query);
    final items = <String>{};
    final svc = BooklService();

    for (final c in svc.cursos) {
      if (_normalizar(c.nombre).contains(q)) {
        items.add(c.nombre);
      }
    }
    for (final l in svc.lecciones) {
      if (_normalizar(l.nombre).contains(q)) {
        items.add(l.nombre);
      }
    }
    for (final u in svc.usuarios) {
      if (_normalizar(u.nombreCompleto).contains(q)) {
        items.add(u.nombreCompleto);
      }
    }

    return items.take(6).toList();
  }

  // ── Historial persistido con SharedPreferences ───────────────────────────
  String _getHistorialKey(int userId) => 'busqueda_historial_$userId';

  @override
  Future<List<String>> cargarHistorial(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_getHistorialKey(userId)) ?? [];
  }

  @override
  Future<void> guardarHistorial(int userId, List<String> historial) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_getHistorialKey(userId), historial);
  }

  // ── Helpers para enriquecer resultados ────────────────────────────────────
  String? _extraerImagenUrl(List<dynamic>? contenido) {
    if (contenido == null || contenido.isEmpty) return null;
    final first = contenido.first;
    if (first is Map && first['tiene_imagen'] == true) {
      return first['imagen_url']?.toString();
    }
    return null;
  }

  String? _autorDeCurso(BooklService svc, int idUsuario) {
    final autor =
        svc.usuarios.where((u) => u.idUsuario == idUsuario).firstOrNull;
    return autor?.nombreCompleto;
  }

  String? _cursoDeLeccion(BooklService svc, int idLeccion) {
    final link = svc.leccionesCursos
        .where((r) => r['id_leccion'] == idLeccion)
        .firstOrNull;
    if (link == null) return null;
    final curso =
        svc.cursos.where((c) => c.idCurso == link['id_curso']).firstOrNull;
    return curso?.nombre;
  }
}
