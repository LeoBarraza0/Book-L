import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Modelo de Resultado de Búsqueda ──────────────────────────────────────────
class ResultadoBusqueda {
  final int id;
  final String tipo;
  final String titulo;
  final String? subtitulo;
  final String? imagenUrl;
  final String? username;   // para Autores: su @username
  final String? avatarUrl;  // para Autores: URL del avatar
  final String calificacion;
  final int inscripciones;
  final double progreso;
  final Color colorTarjeta;

  const ResultadoBusqueda({
    required this.id,
    required this.tipo,
    required this.titulo,
    this.subtitulo,
    this.imagenUrl,
    this.username,
    this.avatarUrl,
    this.calificacion = '4.9',
    this.inscripciones = 0,
    this.progreso = 0.0,
    required this.colorTarjeta,
  });
}

// ── Normalización: elimina tildes y pasa a minúsculas ────────────────────────
String _normalizar(String texto) {
  const Map<String, String> reemplazos = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
    'ñ': 'n', 'Ñ': 'n', 'ü': 'u', 'Ü': 'u',
  };
  return texto.toLowerCase().replaceAllMapped(
    RegExp('[áéíóúÁÉÍÓÚñÑüÜ]'),
    (m) => reemplazos[m.group(0)!] ?? m.group(0)!,
  );
}

// ── Paleta de colores para tarjetas ─────────────────────────────────────────
const List<Color> _paleta = [
  Color(0xFF9DE596), Color(0xFF96D4DB), Color(0xFF888BC6),
  Color(0xFFFA8E9E), Color(0xFFF6CE74), Color(0xFFB5D3F2),
];
Color _colorPorId(int id) => _paleta[id % _paleta.length];

// ── Repositorio ──────────────────────────────────────────────────────────────
class BusquedaRepository {
  // Carga y decodifica el JSON una sola vez
  Future<Map<String, dynamic>> _cargarJson() async {
    final raw = await rootBundle.loadString('assets/data/bookl_data.json');
    return json.decode(raw) as Map<String, dynamic>;
  }

  // ── Búsqueda principal ────────────────────────────────────────────────────
  Future<List<ResultadoBusqueda>> buscar(
    String query, {
    String filtro = 'Todos',
  }) async {
    if (query.trim().isEmpty) return [];

    final data = await _cargarJson();
    final q = _normalizar(query);
    final resultados = <ResultadoBusqueda>[];

    // ── Cursos ───────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Cursos') {
      final cursos = List<Map<String, dynamic>>.from(data['cursos'] ?? []);
      for (final c in cursos) {
        if (_normalizar(c['nombre'] as String).contains(q)) {
          // Extraer imagen del primer contenido del curso
          final contenido = c['contenido'] as List<dynamic>?;
          final imagenUrl = contenido != null && contenido.isNotEmpty
              ? contenido.first['imagen_url'] as String?
              : null;
          resultados.add(ResultadoBusqueda(
            id: c['id_curso'] as int,
            tipo: 'Curso',
            titulo: c['nombre'] as String,
            subtitulo: _autorDeCurso(data, c['id_usuario_fk'] as int),
            imagenUrl: imagenUrl,
            colorTarjeta: _colorPorId(c['id_curso'] as int),
            inscripciones: _inscripcionesCurso(data, c['id_curso'] as int),
          ));
        }
      }
    }

    // ── Lecciones ────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Lecciones') {
      final lecciones = List<Map<String, dynamic>>.from(data['lecciones'] ?? []);
      for (final l in lecciones) {
        if (_normalizar(l['nombre'] as String).contains(q)) {
          final contenido = l['contenido'] as List<dynamic>?;
          final imagenUrl = contenido != null && contenido.isNotEmpty
              ? contenido.first['imagen_url'] as String?
              : null;
          resultados.add(ResultadoBusqueda(
            id: l['id_leccion'] as int,
            tipo: 'Lección',
            titulo: l['nombre'] as String,
            subtitulo: _cursoDeLeccion(data, l['id_leccion'] as int),
            imagenUrl: imagenUrl,
            colorTarjeta: _colorPorId((l['id_leccion'] as int) + 3),
          ));
        }
      }
    }

    // ── Autores ──────────────────────────────────────────────────────────────
    if (filtro == 'Todos' || filtro == 'Autores') {
      final usuarios = List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
      for (final u in usuarios) {
        // Excluir administradores de los resultados
        final rol = (u['rol'] as String? ?? '').toLowerCase();
        if (rol == 'administrador') continue;

        final nombre = u['nombre_completo'] as String;
        if (_normalizar(nombre).contains(q)) {
          resultados.add(ResultadoBusqueda(
            id: u['id_usuario'] as int,
            tipo: 'Autor',
            titulo: nombre,
            subtitulo: u['programa'] as String?,
            imagenUrl: u['avatar_url'] as String?,
            username: u['username'] as String?,
            avatarUrl: u['avatar_url'] as String?,
            colorTarjeta: _colorPorId((u['id_usuario'] as int) + 5),
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
  Future<List<String>> sugerencias(String query) async {
    if (query.trim().length < 2) return [];

    final data = await _cargarJson();
    final q = _normalizar(query);
    final items = <String>{};

    for (final c in List<Map<String, dynamic>>.from(data['cursos'] ?? [])) {
      if (_normalizar(c['nombre'] as String).contains(q)) {
        items.add(c['nombre'] as String);
      }
    }
    for (final l in List<Map<String, dynamic>>.from(data['lecciones'] ?? [])) {
      if (_normalizar(l['nombre'] as String).contains(q)) {
        items.add(l['nombre'] as String);
      }
    }
    for (final u in List<Map<String, dynamic>>.from(data['usuarios'] ?? [])) {
      if (_normalizar(u['nombre_completo'] as String).contains(q)) {
        items.add(u['nombre_completo'] as String);
      }
    }

    return items.take(6).toList();
  }

  // ── Historial persistido con SharedPreferences ───────────────────────────
  static const _historialKey = 'busqueda_historial';

  Future<List<String>> cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historialKey) ?? [];
  }

  Future<void> guardarHistorial(List<String> historial) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historialKey, historial);
  }

  // ── Helpers para enriquecer resultados ────────────────────────────────────
  String? _autorDeCurso(Map<String, dynamic> data, int idUsuario) {
    final usuarios = List<Map<String, dynamic>>.from(data['usuarios'] ?? []);
    final autor = usuarios.where((u) => u['id_usuario'] == idUsuario).firstOrNull;
    return autor?['nombre_completo'] as String?;
  }

  String? _cursoDeLeccion(Map<String, dynamic> data, int idLeccion) {
    final rel = List<Map<String, dynamic>>.from(data['lecciones_cursos'] ?? []);
    final cursos = List<Map<String, dynamic>>.from(data['cursos'] ?? []);
    final link = rel.where((r) => r['id_leccion'] == idLeccion).firstOrNull;
    if (link == null) return null;
    final curso = cursos.where((c) => c['id_curso'] == link['id_curso']).firstOrNull;
    return curso?['nombre'] as String?;
  }

  int _inscripcionesCurso(Map<String, dynamic> data, int idCurso) {
    // Por ahora usamos el número de usuarios que siguen al autor del curso
    final cursos = List<Map<String, dynamic>>.from(data['cursos'] ?? []);
    final curso = cursos.where((c) => c['id_curso'] == idCurso).firstOrNull;
    if (curso == null) return 0;
    final idAutor = curso['id_usuario_fk'] as int;
    final seguidores = List<Map<String, dynamic>>.from(data['seguidores'] ?? []);
    return seguidores.where((s) => s['id_seguido'] == idAutor).length;
  }
}
