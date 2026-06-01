import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/domain/models/pregunta.dart';
import 'package:book_l/features/ejercicio/domain/models/opcion.dart';

class EjercicioDto {
  static Ejercicio fromJson(Map<String, dynamic> j) => Ejercicio(
        idEjercicio: j['id_ejercicio'] as int,
        idCapitulo: j['id_capitulo'] as int,
        tipo: TipoEjercicio.fromString(j['tipo'] as String),
        titulo: j['titulo'] as String? ?? 'Ejercicio #${j['id_ejercicio']}',
        descripcion:
            j['descripcion'] as String? ?? 'Descripción de la actividad',
      );

  static Map<String, dynamic> toJson(Ejercicio e) => {
        'id_ejercicio': e.idEjercicio,
        'id_capitulo': e.idCapitulo,
        'tipo': e.tipo.name,
        'titulo': e.titulo,
        'descripcion': e.descripcion,
      };
}

class PreguntaDto {
  static Pregunta fromJson(Map<String, dynamic> j) => Pregunta(
        idPregunta: j['id_pregunta'] as int,
        idEjercicioFk: j['id_ejercicio_fk'] as int,
        contenido: j['contenido'] as String,
        explicacion: j['explicacion'] as String?,
      );

  static Map<String, dynamic> toJson(Pregunta p) => {
        'id_pregunta': p.idPregunta,
        'id_ejercicio_fk': p.idEjercicioFk,
        'contenido': p.contenido,
        'explicacion': p.explicacion,
      };
}

class OpcionDto {
  static Opcion fromJson(Map<String, dynamic> j) => Opcion(
        idOpcion: j['id_opcion'] as int,
        idPreguntaFk: j['id_pregunta_fk'] as int,
        contenido: j['contenido'] as String,
        correcta:
            (j['correcta'] is int) ? j['correcta'] == 1 : j['correcta'] == true,
      );

  static Map<String, dynamic> toJson(Opcion o) => {
        'id_opcion': o.idOpcion,
        'id_pregunta_fk': o.idPreguntaFk,
        'contenido': o.contenido,
        'correcta': o.correcta ? 1 : 0,
      };
}
