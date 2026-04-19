import 'package:flutter/foundation.dart';

import '../../../../core/state/data_state.dart';
import '../../../../core/services/bookl_service.dart';
import '../../data/repositories/leccion_repository_impl.dart';
import '../../data/repositories/capitulo_repository_impl.dart';
import '../../domain/entities/leccion.dart';
import '../../domain/entities/capitulo.dart';
import '../../domain/usecases/leccion_usecases.dart';

// Adaptador primario — maneja Lección y Capítulo juntos porque en la UI
// siempre se navegan en conjunto (lección → lista de capítulos).
class LeccionController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final LeccionController _instance = LeccionController._internal();
  factory LeccionController() => _instance;
  LeccionController._internal() {
    final service = BooklService();
    final leccionRepo = LeccionRepositoryImpl(service);
    final capituloRepo = CapituloRepositoryImpl(service);

    _getLecciones = GetLeccionesUseCase(leccionRepo);
    _getLeccionById = GetLeccionByIdUseCase(leccionRepo);
    _addLeccion = AddLeccionUseCase(leccionRepo);
    _updateLeccion = UpdateLeccionUseCase(leccionRepo);
    _deleteLeccion = DeleteLeccionUseCase(leccionRepo);
    _getCapitulos = GetCapitulosDeLeccionUseCase(leccionRepo);

    _getCapituloById = GetCapituloByIdUseCase(capituloRepo);
    _addCapitulo = AddCapituloUseCase(capituloRepo);
    _updateCapitulo = UpdateCapituloUseCase(capituloRepo);
    _deleteCapitulo = DeleteCapituloUseCase(capituloRepo);
  }

  // ── Use cases — Lección ───────────────────────────────────────────────────
  late final GetLeccionesUseCase _getLecciones;
  late final GetLeccionByIdUseCase _getLeccionById;
  late final AddLeccionUseCase _addLeccion;
  late final UpdateLeccionUseCase _updateLeccion;
  late final DeleteLeccionUseCase _deleteLeccion;
  late final GetCapitulosDeLeccionUseCase _getCapitulos;

  // ── Use cases — Capítulo ──────────────────────────────────────────────────
  late final GetCapituloByIdUseCase _getCapituloById;
  late final AddCapituloUseCase _addCapitulo;
  late final UpdateCapituloUseCase _updateCapitulo;
  late final DeleteCapituloUseCase _deleteCapitulo;

  // ── Estado ─────────────────────────────────────────────────────────────────
  DataState<Leccion> state = const DataState<Leccion>();

  // Capítulos de la lección seleccionada
  List<Capitulo> capitulosDeLeccion = [];
  Capitulo? capituloSeleccionado;

  // ── READ — Lección ─────────────────────────────────────────────────────────

  Future<void> cargarLecciones() async {
    state = state.copyWith(status: DataStatus.loading);
    notifyListeners();
    try {
      final lecciones = await _getLecciones();
      state = state.copyWith(status: DataStatus.loaded, items: lecciones);
    } catch (e) {
      state = state.copyWith(
          status: DataStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  Future<void> seleccionarLeccion(int id) async {
    try {
      final leccion = await _getLeccionById(id);
      if (leccion != null) {
        state = state.copyWith(selected: leccion);
        capitulosDeLeccion = await _getCapitulos(id);
      }
    } catch (e) {
      state = state.copyWith(
          status: DataStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  // ── CREATE — Lección ───────────────────────────────────────────────────────

  Future<void> agregarLeccion({
    required int idUsuario,
    required String nombre,
    List<dynamic>? contenido,
  }) async {
    final nueva = Leccion(
      idLeccion: 0, // el impl asigna el ID real
      idUsuarioFk: idUsuario,
      nombre: nombre,
      contenido: contenido,
      estado: 'activa',
    );
    await _addLeccion(nueva);
    await cargarLecciones();
  }

  // ── UPDATE — Lección ───────────────────────────────────────────────────────

  Future<void> editarLeccion(Leccion leccion) async {
    await _updateLeccion(leccion);
    await cargarLecciones();
    if (state.selected?.idLeccion == leccion.idLeccion) {
      state = state.copyWith(selected: leccion);
      notifyListeners();
    }
  }

  // ── DELETE — Lección ───────────────────────────────────────────────────────

  Future<void> eliminarLeccion(int id) async {
    await _deleteLeccion(id); // cascada incluye capítulos y pivote
    if (state.selected?.idLeccion == id) {
      capitulosDeLeccion = [];
      state = DataState<Leccion>(
          status: DataStatus.loaded, items: state.items);
    }
    await cargarLecciones();
  }

  // ── READ — Capítulo ────────────────────────────────────────────────────────

  Future<void> seleccionarCapitulo(int id) async {
    try {
      final cap = await _getCapituloById(id);
      capituloSeleccionado = cap;
    } catch (e) {
      // Manejo de error silencioso o log
    }
    notifyListeners();
  }

  Future<Capitulo?> obtenerCapitulo(int id) => _getCapituloById(id);

  /// Devuelve los capítulos ya en memoria de una lección.
  /// Consulta directa a BooklService (síncrona) para uso en cards de lista.
  List<Capitulo> capitulosDe(int idLeccion) =>
      BooklService().capitulos.where((c) => c.idLeccion == idLeccion).toList();

  // ── CREATE — Capítulo ──────────────────────────────────────────────────────

  Future<void> agregarCapitulo({
    required int idLeccion,
    required String nombre,
    List<dynamic>? contenido,
    int tiempoTotal = 0,
  }) async {
    final nuevo = Capitulo(
      idCapitulo: 0, // el impl asigna el ID real
      idLeccion: idLeccion,
      nombre: nombre,
      contenido: contenido,
      tiempoTotal: tiempoTotal,
    );
    await _addCapitulo(nuevo);
    // Refresca la lista de capítulos si la lección seleccionada coincide
    if (state.selected?.idLeccion == idLeccion) {
      capitulosDeLeccion = await _getCapitulos(idLeccion);
      notifyListeners();
    }
  }

  // ── UPDATE — Capítulo ──────────────────────────────────────────────────────

  Future<void> editarCapitulo(Capitulo capitulo) async {
    await _updateCapitulo(capitulo);
    if (capituloSeleccionado?.idCapitulo == capitulo.idCapitulo) {
      capituloSeleccionado = capitulo;
    }
    if (state.selected?.idLeccion == capitulo.idLeccion) {
      capitulosDeLeccion = await _getCapitulos(capitulo.idLeccion);
    }
    notifyListeners();
  }

  // ── DELETE — Capítulo ──────────────────────────────────────────────────────

  Future<void> eliminarCapitulo(int idCapitulo, int idLeccion) async {
    await _deleteCapitulo(idCapitulo);
    if (state.selected?.idLeccion == idLeccion) {
      capitulosDeLeccion = await _getCapitulos(idLeccion);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Es un Singleton, no debe destruirse nunca para evitar errores de 'used after being disposed'.
  }
}
