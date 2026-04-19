import '../../domain/entities/capitulo.dart';

class CapituloDto {
  static Capitulo fromJson(Map<String, dynamic> json) {
    return Capitulo(
      idCapitulo: json['id_capitulo'] as int,
      idLeccion: json['id_leccion'] as int,
      nombre: json['nombre'] as String,
      contenido: (json['contenido'] as List<dynamic>?),
      tiempoTotal: json['tiempo_total'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toJson(Capitulo capitulo) {
    return {
      'id_capitulo': capitulo.idCapitulo,
      'id_leccion': capitulo.idLeccion,
      'nombre': capitulo.nombre,
      'contenido': capitulo.contenido,
      'tiempo_total': capitulo.tiempoTotal,
    };
  }
}
