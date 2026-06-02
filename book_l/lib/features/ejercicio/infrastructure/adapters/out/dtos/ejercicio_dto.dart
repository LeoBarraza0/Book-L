import 'package:book_l/features/ejercicio/domain/models/ejercicio.dart';
import 'package:book_l/features/ejercicio/domain/models/pregunta.dart';
import 'package:book_l/features/ejercicio/domain/models/opcion.dart';

class EjercicioDto {
  static Ejercicio fromJson(Map<String, dynamic> j) => Ejercicio(
        idEjercicio: (j['idejercicio'] ?? j['id_ejercicio']) as int,
        idCapitulo: (j['idcapitulo'] ?? j['id_capitulo']) as int,
        tipo: TipoEjercicio.fromString(j['tipo'] as String),
        titulo: j['titulo'] as String? ?? 'Ejercicio #${j['idejercicio'] ?? j['id_ejercicio']}',
        descripcion:
            j['descripcion'] as String? ?? 'Descripción de la actividad',
      );

  static Map<String, dynamic> toJson(Ejercicio e) => {
        'idejercicio': e.idEjercicio,
        'idcapitulo': e.idCapitulo,
        'tipo': e.tipo.name,
        'titulo': e.titulo,
        'descripcion': e.descripcion,
      };
}

class PreguntaDto {
  static Pregunta fromJson(Map<String, dynamic> j) => Pregunta(
        idPregunta: (j['idpregunta'] ?? j['id_pregunta']) as int,
        idEjercicioFk: (j['idejerciciofk'] ?? j['id_ejercicio_fk']) as int,
        contenido: j['contenido'] as String,
        explicacion: j['explicacion'] as String?,
      );

  static Map<String, dynamic> toJson(Pregunta p) => {
        'idpregunta': p.idPregunta,
        'idejerciciofk': p.idEjercicioFk,
        'contenido': p.contenido,
        'explicacion': p.explicacion,
      };
}

class OpcionDto {
  static Opcion fromJson(Map<String, dynamic> j) => Opcion(
        idOpcion: (j['idopcion'] ?? j['id_opcion']) as int,
        idPreguntaFk: (j['idpreguntafk'] ?? j['id_pregunta_fk']) as int,
        contenido: j['contenido'] as String,
        correcta:
            (j['correcta'] is int) ? j['correcta'] == 1 : j['correcta'] == true,
      );

  static Map<String, dynamic> toJson(Opcion o) => {
        'idopcion': o.idOpcion,
        'idpreguntafk': o.idPreguntaFk,
        'contenido': o.contenido,
        'correcta': o.correcta ? 1 : 0,
      };
}
