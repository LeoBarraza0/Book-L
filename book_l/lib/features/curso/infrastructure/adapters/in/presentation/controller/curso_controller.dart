import 'package:flutter/foundation.dart';

import 'package:book_l/core/state/data_state.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/curso/infrastructure/adapters/out/repositories/curso_repository_impl.dart';
import 'package:book_l/features/curso/domain/models/curso.dart';
import 'package:book_l/features/curso/application/usecases/curso_usecases.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/in/presentation/controller/leccion_controller.dart';

// Adaptador primario — orquesta los casos de uso y notifica a la UI.
// La UI solo lo instancia e invoca sus métodos; nunca toca repositorios.
class CursoController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final CursoController _instance = CursoController._internal();
  factory CursoController() => _instance;
  CursoController._internal() {
    final repo = CursoRepositoryImpl(BooklService());
    _getCursos = GetCursosUseCase(repo);
    _getCursoById = GetCursoByIdUseCase(repo);
    _addCurso = AddCursoUseCase(repo);
    _updateCurso = UpdateCursoUseCase(repo);
    _deleteCurso = DeleteCursoUseCase(repo);
    _getLecciones = GetLeccionesDeCursoUseCase(repo);
    _asociar = AsociarLeccionACursoUseCase(repo);
    _desasociar = DesasociarLeccionDeCursoUseCase(repo);
  }

  // ── Use cases ──────────────────────────────────────────────────────────────
  late final GetCursosUseCase _getCursos;
  late final GetCursoByIdUseCase _getCursoById;
  late final AddCursoUseCase _addCurso;
  late final UpdateCursoUseCase _updateCurso;
  late final DeleteCursoUseCase _deleteCurso;
  late final GetLeccionesDeCursoUseCase _getLecciones;
  late final AsociarLeccionACursoUseCase _asociar;
  late final DesasociarLeccionDeCursoUseCase _desasociar;

  // ── Estado ─────────────────────────────────────────────────────────────────
  DataState<Curso> state = const DataState<Curso>();

  // Lecciones del curso seleccionado
  List<Leccion> leccionesDeCurso = [];

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<void> cargarCursos() async {
    state = state.copyWith(status: DataStatus.loading);
    notifyListeners();
    try {
      final cursos = await _getCursos();
      state = state.copyWith(status: DataStatus.loaded, items: cursos);
    } catch (e) {
      state =
          state.copyWith(status: DataStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> seleccionarCurso(int id) async {
    try {
      final curso = await _getCursoById(id);
      if (curso != null) {
        state = state.copyWith(selected: curso);
        leccionesDeCurso = (await _getLecciones(id)).cast<Leccion>();
      }
    } catch (e) {
      state =
          state.copyWith(status: DataStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> agregarCurso({
    required int idUsuario,
    required String nombre,
    List<dynamic>? contenido,
    String? imagenUrl,
  }) async {
    final nuevo = Curso(
      idCurso: 0, // el impl asigna el ID real
      idUsuarioFk: idUsuario,
      nombre: nombre,
      contenido: contenido,
      imagenUrl: imagenUrl,
      estado: 'activo',
    );
    await _addCurso(nuevo);
    await cargarCursos();
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<void> editarCurso(Curso curso) async {
    await _updateCurso(curso);
    await cargarCursos();
    if (state.selected?.idCurso == curso.idCurso) {
      state = state.copyWith(selected: curso);
      notifyListeners();
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<void> eliminarCurso(int id) async {
    await _deleteCurso(id);
    if (state.selected?.idCurso == id) {
      state = DataState<Curso>(status: DataStatus.loaded, items: state.items);
    }
    await cargarCursos();
  }

  // ── PIVOTE M:N ────────────────────────────────────────────────────────────

  Future<void> asociarLeccion(int idCurso, int idLeccion) async {
    await _asociar(idCurso, idLeccion);
    if (state.selected?.idCurso == idCurso) {
      leccionesDeCurso = (await _getLecciones(idCurso)).cast<Leccion>();
      notifyListeners();
    }
  }

  Future<void> desasociarLeccion(int idCurso, int idLeccion) async {
    await _desasociar(idCurso, idLeccion);
    if (state.selected?.idCurso == idCurso) {
      leccionesDeCurso = (await _getLecciones(idCurso)).cast<Leccion>();
      notifyListeners();
    }
  }

  /// Calcula el progreso de un curso basado en el progreso de sus lecciones.
  double calcularProgresoCurso(int idCurso) {
    final leccs = BooklService()
        .leccionesCursos
        .where((lc) => lc['id_curso'] == idCurso)
        .map((lc) => lc['id_leccion'])
        .toList();

    if (leccs.isEmpty) return 0.0;

    final leccionCtrl = LeccionController();
    double totalProgress = 0.0;
    for (var idL in leccs) {
      totalProgress += leccionCtrl.calcularProgresoLeccion(idL!);
    }

    return totalProgress / leccs.length;
  }

  /// Obtiene de forma síncrona la información del creador para la UI.
  /// Se usa para no bloquear la construcción de la pantalla de detalles.
  dynamic getCreadorSync(int idUsuario) {
    try {
      return BooklService()
          .usuarios
          .firstWhere((u) => u.idUsuario == idUsuario);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    // Es un Singleton, no debe destruirse nunca para evitar errores de 'used after being disposed'.
  }
}
