import '../domain/models/leccion_model.dart';
import '../../core/services/bookl_service.dart';
import '../../features/leccion/domain/entities/leccion.dart';
import '../../features/leccion/domain/entities/capitulo.dart';
import 'package:flutter/foundation.dart';

/// Puente singleton entre la UI (LeccionModel) y el almacenamiento centralizado (BooklService).
/// Escucha cambios de BooklService para mantener la UI reactiva.
class LeccionRepository {
  LeccionRepository._internal() {
    BooklService().addListener(_syncFromCentral);
    _syncFromCentral();
  }
  static final LeccionRepository instance = LeccionRepository._internal();

  final ValueNotifier<List<LeccionModel>> leccionesNotifier =
      ValueNotifier<List<LeccionModel>>([]);

  List<LeccionModel> get lecciones => leccionesNotifier.value;

  /// Sincroniza desde BooklService convirtiendo Entidades → Modelos de UI.
  void _syncFromCentral() {
    leccionesNotifier.value = BooklService().lecciones.map((l) {
      // Buscar el curso al que pertenece esta lección (relación M:N)
      final relacion = BooklService().leccionesCursos
          .firstWhere((lc) => lc['id_leccion'] == l.idLeccion, orElse: () => {});

      return LeccionModel(
        id: l.idLeccion,
        idCursoFk: relacion['id_curso'],
        nombre: l.nombre,
        contenido: l.contenido?.toString() ?? '',
        rating: l.rating,
        duracion: l.duracion,
        estudiantes: l.estudiantes,
        progreso: l.progreso,
        tagColor: l.tagColor,
        esNuevo: l.esNuevo,
        capitulos: [],
      );
    }).toList();
  }

  /// Persiste una lección (con sus capítulos) en BooklService.
  Future<void> addLeccion(LeccionModel model) async {
    final entity = Leccion(
      idLeccion: model.id,
      idUsuarioFk: 1,
      nombre: model.nombre,
      rating: model.rating,
      duracion: model.duracion,
      estudiantes: model.estudiantes,
      progreso: model.progreso,
      tagColor: model.tagColor,
      esNuevo: model.esNuevo,
      estado: 'activa',
      createdAt: DateTime.now(),
    );
    BooklService().addLeccion(entity, idCurso: model.idCursoFk);

    for (var cap in model.capitulos) {
      final capEntity = Capitulo(
        idCapitulo: cap.id,
        idLeccion: model.id,
        nombre: cap.nombre,
        contenido: cap.secciones,
        tiempoTotal: 0,
      );
      BooklService().addCapitulo(capEntity);
    }
  }

  LeccionModel? getLeccionById(int id) {
    try {
      return leccionesNotifier.value.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void removeLeccion(int id) => BooklService().removeLeccion(id);

  Future<void> clear() async => BooklService().clearAllData();
}
