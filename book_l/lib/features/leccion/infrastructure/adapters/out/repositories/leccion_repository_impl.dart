import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/domain/models/material_educativo.dart';
import 'package:book_l/features/leccion/application/ports/out/leccion_repository.dart';

class LeccionRepositoryImpl implements LeccionRepository {
  final BooklService _service;

  LeccionRepositoryImpl(this._service);

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Leccion>> getLecciones() async {
    return List.unmodifiable(_service.lecciones);
  }

  @override
  Future<Leccion?> getLeccionById(int id) async {
    try {
      return _service.lecciones.firstWhere((l) => l.idLeccion == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Capitulo>> getCapitulosDeLeccion(int idLeccion) async {
    return _service.capitulos.where((c) => c.idLeccion == idLeccion).toList();
  }

  /// Devuelve capítulos de forma síncrona (ya cargados en memoria)
  @override
  List<Capitulo> capitulosDe(int idLeccion) =>
      _service.capitulos.where((c) => c.idLeccion == idLeccion).toList();

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<int> addLeccion(Leccion leccion) async {
    final newId = _service.nextLeccionId();
    final nueva = leccion.copyWith(idLeccion: newId);
    _service.addLeccion(nueva);
    return newId;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateLeccion(Leccion leccion) async {
    _service.updateLeccion(leccion);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteLeccion(int id) async {
    _service.removeLeccion(id);
  }

  // ── Material Educativo ─────────────────────────────────────────────────────

  @override
  List<MaterialEducativo> materialesDeLeccion(int idLeccion) =>
      _service.materialesDeLeccion(idLeccion);

  @override
  int agregarMaterial(MaterialEducativo material) {
    final id = _service.nextMaterialId();
    final nuevo = material.copyWith(idMaterial: id);
    _service.addMaterial(nuevo);
    return id;
  }

  @override
  void actualizarMaterial(MaterialEducativo material) {
    _service.updateMaterial(material);
  }

  @override
  void eliminarMaterial(int idMaterial) {
    _service.removeMaterial(idMaterial);
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  @override
  int generarId() => _service.generateId();

  @override
  dynamic getUsuarioById(int idUsuario) {
    try {
      return _service.usuarios.firstWhere((u) => u.idUsuario == idUsuario);
    } catch (_) {
      return null;
    }
  }

  @override
  List<dynamic> getCursosAsociados(int idLeccion) {
    final asociadosIds = _service.leccionesCursos
        .where((e) => e['id_leccion'] == idLeccion)
        .map((e) => e['id_curso'])
        .toList();
    return _service.cursos
        .where((c) => asociadosIds.contains(c.idCurso))
        .toList();
  }
}
