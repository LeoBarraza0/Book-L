import '../../../../core/services/bookl_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class BusquedaRepository {
  Future<List<Map<String, dynamic>>> buscarCursos(String query, {String filtro = 'Todas'}) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/bookl_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> cursosRaw = jsonData['cursos'] ?? [];
      
      List<Map<String, dynamic>> cursos = List<Map<String, dynamic>>.from(cursosRaw);
      
      // Filtrar por término de búsqueda en el nombre del curso
      if (query.isNotEmpty) {
        cursos = cursos.where((c) {
          final nombre = c['nombre'].toString().toLowerCase();
          return nombre.contains(query.toLowerCase());
        }).toList();
      }
      
      // Mapear los resultados al formato esperado por la UI
      return cursos.map((c) {
        return {
          'id_curso': c['id_curso'],
          'tags': [
            {
              'text': 'Curso',
              'color': const Color(0xFF67C947),
              'textColor': const Color(0xFFFFFFFF),
            }
          ],
          'titulo': c['nombre'],
          'duracion': 'Variable', // Idealmente calcular basado en lecciones
          'calificacion': '4.9', // Hardcodeado como en Figma por ahora
          'estudiantes': '1.200', // Hardcodeado
          'progreso': 0.0, // Progreso del usuario actual (0.0 por defecto)
          'favorito': false,
          'imageColor': const Color(0xFF9DE596),
        };
      }).toList();
    } catch (e) {
      print('Error buscando cursos: $e');
      return [];
    }
  }

  // Guardar historial de búsquedas usando SharedPreferences o similar
  // Para fines de esta demostración, mantenemos una lista en memoria o usamos el BooklService.
}
