import 'package:flutter/foundation.dart';

import 'package:book_l/core/state/data_state.dart';
import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/repositories/leccion_repository_impl.dart';
import 'package:book_l/features/leccion/infrastructure/adapters/out/repositories/capitulo_repository_impl.dart';
import 'package:book_l/features/leccion/domain/models/leccion.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/domain/models/material_educativo.dart';
import 'package:book_l/features/leccion/application/usecases/leccion_usecases.dart';
import 'package:book_l/features/leccion/application/usecases/create_material_educativo_usecase.dart';
import 'package:book_l/features/leccion/application/usecases/delete_material_educativo_usecase.dart';
import 'package:book_l/features/leccion/application/usecases/update_material_educativo_usecase.dart';
import 'package:book_l/core/infrastructure/storage/local_storage.dart';

/// Adaptador primario — maneja Lección y Capítulo juntos porque en la UI
/// siempre se navegan en conjunto (lección → lista de capítulos).
class LeccionController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final LeccionController _instance = LeccionController._internal();
  factory LeccionController() => _instance;
  LeccionController._internal() {
    final service = BooklService();
    _leccionRepo = LeccionRepositoryImpl(service);
    final capituloRepo = CapituloRepositoryImpl(service);

    // Casos de uso de lección
    _getLecciones = GetLeccionesUseCase(_leccionRepo);
    _getCapitulos = GetCapitulosDeLeccionUseCase(_leccionRepo);
    _getLeccionById = GetLeccionByIdUseCase(_leccionRepo, _getCapitulos);
    _addLeccion = AddLeccionUseCase(_leccionRepo);
    _updateLeccion = UpdateLeccionUseCase(_leccionRepo);
    _deleteLeccion = DeleteLeccionUseCase(_leccionRepo);

    // Casos de uso de capítulo
    _getCapituloById = GetCapituloByIdUseCase(capituloRepo);
    _addCapitulo = AddCapituloUseCase(capituloRepo);
    _updateCapitulo = UpdateCapituloUseCase(capituloRepo);
    _deleteCapitulo = DeleteCapituloUseCase(capituloRepo);

    // Casos de uso de material educativo
    _createMaterial = CreateMaterialEducativoUseCase(_leccionRepo);
    _deleteMaterial = DeleteMaterialEducativoUseCase(_leccionRepo);
    _updateMaterial = UpdateMaterialEducativoUseCase(_leccionRepo);
  }

  // ── Repositorio (acceso directo para operaciones síncronas) ────────────────
  late final LeccionRepositoryImpl _leccionRepo;

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

  // ── Use cases — Material Educativo ────────────────────────────────────────
  late final CreateMaterialEducativoUseCase _createMaterial;
  late final DeleteMaterialEducativoUseCase _deleteMaterial;
  late final UpdateMaterialEducativoUseCase _updateMaterial;

  // ── Estado ─────────────────────────────────────────────────────────────────
  DataState<Leccion> state = const DataState<Leccion>();

  /// Capítulos de la lección seleccionada
  List<Capitulo> capitulosDeLeccion = [];
  Capitulo? capituloSeleccionado;

  // ══════════════════════════════════════════════════════════════════════════
  // READ — Lección
  // ══════════════════════════════════════════════════════════════════════════

  /// Carga todas las lecciones desde el repositorio
  Future<void> cargarLecciones() async {
    state = state.copyWith(status: DataStatus.loading);
    notifyListeners();
    try {
      final lecciones = await _getLecciones();
      state = state.copyWith(status: DataStatus.loaded, items: lecciones);
    } catch (e) {
      state =
          state.copyWith(status: DataStatus.error, errorMessage: e.toString());
    }
    notifyListeners();
  }

  /// Prepara de forma síncrona el estado de la lección seleccionada usando la memoria caché
  void prepararLeccion(int id) {
    try {
      final leccionLocal = BooklService().lecciones.firstWhere((l) => l.idLeccion == id);
      state = state.copyWith(selected: leccionLocal, status: DataStatus.loaded);
      capitulosDeLeccion = _leccionRepo.capitulosDe(id);
      capituloSeleccionado = null;
    } catch (_) {
      state = state.copyWith(selected: null, status: DataStatus.loading);
      capitulosDeLeccion = [];
      capituloSeleccionado = null;
    }
  }

  /// Selecciona una lección por ID y carga sus capítulos asociados
  Future<void> seleccionarLeccion(int id) async {
    // 1. Cargar local de inmediato por si acaso no se llamó a prepararLeccion previamente
    try {
      final leccionLocal = BooklService().lecciones.firstWhere((l) => l.idLeccion == id);
      if (state.selected?.idLeccion != id) {
        state = state.copyWith(selected: leccionLocal, status: DataStatus.loaded);
        capitulosDeLeccion = _leccionRepo.capitulosDe(id);
        capituloSeleccionado = null;
        notifyListeners();
      }
    } catch (_) {
      if (state.selected != null) {
        state = state.copyWith(selected: null, status: DataStatus.loading);
        capitulosDeLeccion = [];
        capituloSeleccionado = null;
        notifyListeners();
      }
    }

    // 2. Traer la versión actualizada de Supabase de forma asíncrona
    try {
      final leccion = await _getLeccionById(id);
      if (leccion != null) {
        state = state.copyWith(selected: leccion, status: DataStatus.loaded);
        capitulosDeLeccion = await _getCapitulos(id);
        notifyListeners();
      }
    } catch (e) {
      if (state.selected == null) {
        state = state.copyWith(status: DataStatus.error, errorMessage: e.toString());
        notifyListeners();
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE — Lección
  // ══════════════════════════════════════════════════════════════════════════

  /// Crea una nueva lección y recarga la lista
  Future<int> agregarLeccion({
    required int idUsuario,
    required String nombre,
    List<dynamic>? contenido,
    String? imagenUrl,
  }) async {
    final nueva = Leccion(
      idLeccion: 0, // el repositorio asigna el ID real
      idUsuarioFk: idUsuario,
      nombre: nombre,
      contenido: contenido,
      imagenUrl: imagenUrl,
      estado: 'activa',
    );
    final newId = await _addLeccion(nueva);
    await cargarLecciones();
    return newId;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE — Lección
  // ══════════════════════════════════════════════════════════════════════════

  /// Actualiza una lección existente y refresca el estado
  Future<void> editarLeccion(Leccion leccion) async {
    await _updateLeccion(leccion);
    await cargarLecciones();
    if (state.selected?.idLeccion == leccion.idLeccion) {
      state = state.copyWith(selected: leccion);
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE — Lección
  // ══════════════════════════════════════════════════════════════════════════

  /// Elimina una lección y limpia su estado si estaba seleccionada
  Future<void> eliminarLeccion(int id) async {
    await _deleteLeccion(id); // cascada incluye capítulos y pivote
    if (state.selected?.idLeccion == id) {
      capitulosDeLeccion = [];
      state = DataState<Leccion>(status: DataStatus.loaded, items: state.items);
    }
    await cargarLecciones();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // READ — Capítulo
  // ══════════════════════════════════════════════════════════════════════════

  /// Prepara de forma síncrona el capítulo usando la memoria caché
  void prepararCapitulo(int id) {
    try {
      capituloSeleccionado = BooklService().capitulos.firstWhere((c) => c.idCapitulo == id);
    } catch (_) {
      capituloSeleccionado = null;
    }
  }

  /// Selecciona un capítulo por ID para ver su detalle
  Future<void> seleccionarCapitulo(int id) async {
    // 1. Cargar de memoria caché de inmediato
    try {
      final capLocal = BooklService().capitulos.firstWhere((c) => c.idCapitulo == id);
      if (capituloSeleccionado?.idCapitulo != id) {
        capituloSeleccionado = capLocal;
        notifyListeners();
      }
    } catch (_) {
      if (capituloSeleccionado != null) {
        capituloSeleccionado = null;
        notifyListeners();
      }
    }

    // 2. Traer versión fresca de Supabase
    try {
      final cap = await _getCapituloById(id);
      if (cap != null) {
        capituloSeleccionado = cap;
        notifyListeners();
      }
    } catch (_) {
      // Error silencioso — el capítulo puede no existir
    }
  }

  /// Obtiene un capítulo por ID (asíncrono)
  Future<Capitulo?> obtenerCapitulo(int id) => _getCapituloById(id);

  /// Devuelve los capítulos en memoria de una lección (síncrono, vía repositorio)
  List<Capitulo> capitulosDe(int idLeccion) =>
      _leccionRepo.capitulosDe(idLeccion);

  /// Calcula el progreso de una lección basado en capítulos completados
  double calcularProgresoLeccion(int idLeccion) {
    final caps = capitulosDe(idLeccion);
    if (caps.isEmpty) return 0.0;

    final completados = AppSession().completedCapitulos.value;
    int count = 0;
    for (var c in caps) {
      if (completados.contains(c.idCapitulo)) count++;
    }
    return count / caps.length;
  }

  /// Obtiene de forma síncrona la información de un usuario/creador para la UI
  dynamic getCreadorSync(int idUsuario) =>
      _leccionRepo.getUsuarioById(idUsuario);

  /// Obtiene los cursos asociados a una lección (relación N:M)
  List<dynamic> getCursosAsociados(int idLeccion) =>
      _leccionRepo.getCursosAsociados(idLeccion);

  // ══════════════════════════════════════════════════════════════════════════
  // CREATE — Capítulo
  // ══════════════════════════════════════════════════════════════════════════

  /// Crea un nuevo capítulo y refresca la lista si pertenece a la lección activa
  Future<int> agregarCapitulo({
    required int idLeccion,
    required String nombre,
    List<dynamic>? contenido,
    int tiempoTotal = 0,
  }) async {
    final nuevo = Capitulo(
      idCapitulo: 0, // el repositorio asigna el ID real
      idLeccion: idLeccion,
      nombre: nombre,
      contenido: contenido,
      tiempoTotal: tiempoTotal,
    );
    final newId = await _addCapitulo(nuevo);
    // Refresca la lista de capítulos si la lección seleccionada coincide
    if (state.selected?.idLeccion == idLeccion) {
      capitulosDeLeccion = await _getCapitulos(idLeccion);
      notifyListeners();
    }
    return newId;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPDATE — Capítulo
  // ══════════════════════════════════════════════════════════════════════════

  /// Actualiza un capítulo existente y refresca la lista
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

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE — Capítulo
  // ══════════════════════════════════════════════════════════════════════════

  /// Elimina un capítulo y refresca la lista
  Future<void> eliminarCapitulo(int idCapitulo, int idLeccion) async {
    await _deleteCapitulo(idCapitulo);
    if (state.selected?.idLeccion == idLeccion) {
      capitulosDeLeccion = await _getCapitulos(idLeccion);
      notifyListeners();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CRUD — Material Educativo (delegado al repositorio)
  // ══════════════════════════════════════════════════════════════════════════

  /// Obtiene materiales de una lección
  List<MaterialEducativo> materialesDeLeccion(int idLeccion) =>
      _leccionRepo.materialesDeLeccion(idLeccion);

  /// Agrega un material educativo a una lección
  int agregarMaterial({
    required int idLeccion,
    required String nombre,
    required String tipo,
    String? url,
    String? descripcion,
    int tamanoBytes = 0,
  }) {
    final m = MaterialEducativo(
      idMaterial: 0, // el repositorio asigna el ID real
      idLeccionFk: idLeccion,
      nombre: nombre,
      tipo: tipo,
      url: url,
      descripcion: descripcion,
      tamanoBytes: tamanoBytes,
    );
    final id = _createMaterial(m);
    notifyListeners();
    return id;
  }

  /// Actualiza un material educativo existente
  void editarMaterial(MaterialEducativo material) {
    _updateMaterial(material);
    notifyListeners();
  }

  /// Elimina un material educativo por ID
  void eliminarMaterial(int idMaterial) {
    _deleteMaterial(idMaterial);
    notifyListeners();
  }

  /// Genera un ID único (delegado al repositorio)
  int generarId() => _leccionRepo.generarId();

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton — no debe destruirse para evitar errores de 'used after being disposed'
  }
}
