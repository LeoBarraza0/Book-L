// Entidad pura de dominio — sin imports de Flutter ni de paquetes externos.
// Corresponde a Tbl_curso del modelo relacional.
import '../../../discusion/domain/models/discusion.dart';

class Curso {
  final int idCurso;
  final int idUsuarioFk;
  final String nombre;
  final List<dynamic>? contenido;
  final String? imagenUrl; // URL o path de la imagen de portada
  final double rating;
  final String duracion;
  final int estudiantes;
  final double progreso;
  final int? tagColor;
  final bool esNuevo;
  final String estado; // 'activo' | 'inactivo' | 'en_revision' | 'suspendido'
  final List<Discusion> discusiones; // Agregado para mapeo relacional

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Curso({
    required this.idCurso,
    required this.idUsuarioFk,
    required this.nombre,
    this.contenido,
    this.imagenUrl,
    this.rating = 0.0,
    this.duracion = '',
    this.estudiantes = 0,
    this.progreso = 0.0,
    this.tagColor,
    this.esNuevo = true,
    required this.estado,
    this.discusiones = const [],
    this.createdAt,
    this.updatedAt,
  });

  Curso copyWith({
    int? idCurso,
    int? idUsuarioFk,
    String? nombre,
    List<dynamic>? contenido,
    String? imagenUrl,
    double? rating,
    String? duracion,
    int? estudiantes,
    double? progreso,
    int? tagColor,
    bool? esNuevo,
    String? estado,
    List<Discusion>? discusiones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Curso(
      idCurso: idCurso ?? this.idCurso,
      idUsuarioFk: idUsuarioFk ?? this.idUsuarioFk,
      nombre: nombre ?? this.nombre,
      contenido: contenido ?? this.contenido,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      rating: rating ?? this.rating,
      duracion: duracion ?? this.duracion,
      estudiantes: estudiantes ?? this.estudiantes,
      progreso: progreso ?? this.progreso,
      tagColor: tagColor ?? this.tagColor,
      esNuevo: esNuevo ?? this.esNuevo,
      estado: estado ?? this.estado,
      discusiones: discusiones ?? this.discusiones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
