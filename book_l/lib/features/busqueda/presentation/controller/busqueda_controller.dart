import 'package:flutter/material.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../../domain/repositories/busqueda_repository.dart';
import '../../data/repositories/busqueda_repository_impl.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../domain/usecases/buscar_contenido_usecase.dart';

class BusquedaController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BusquedaController _instance = BusquedaController._internal();
  factory BusquedaController() => _instance;

  // Repositorio y casos de uso inyectados
  final BusquedaRepository _repository;
  final BuscarContenidoUseCase _buscarContenidoUseCase;

  BusquedaController._internal()
      : _repository = BusquedaRepositoryImpl(),
        _buscarContenidoUseCase = BuscarContenidoUseCase(BusquedaRepositoryImpl()) {
    _cargarHistorial();
  }

  // ── Estado ─────────────────────────────────────────────────────────────────
  List<ResultadoBusqueda> resultados = [];
  List<String> sugerencias = [];
  List<String> historial = [];
  bool isLoading = false;
  bool mostrandoSugerencias = false;
  String currentQuery = '';
  String filtroActivo = 'Todos';

  // Filtros disponibles para la pantalla de resultados
  static const List<String> filtros = ['Todos', 'Cursos', 'Lecciones', 'Autores'];

  // ── Historial (SharedPreferences) ─────────────────────────────────────────
  Future<void> _cargarHistorial() async {
    final userId = AuthController().usuarioActual?.idUsuario ?? 0;
    historial = await _repository.cargarHistorial(userId);
    notifyListeners();
  }

  Future<void> _guardarHistorial() async {
    final userId = AuthController().usuarioActual?.idUsuario ?? 0;
    await _repository.guardarHistorial(userId, historial);
  }

  Future<void> recargarHistorial() async {
    await _cargarHistorial();
  }

  void _agregarAlHistorial(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    historial.remove(q); // evita duplicados
    historial.insert(0, q);
    if (historial.length > 15) historial = historial.sublist(0, 15);
    _guardarHistorial();
  }

  void eliminarDelHistorial(int index) {
    historial.removeAt(index);
    _guardarHistorial();
    notifyListeners();
  }

  void limpiarHistorial() {
    historial.clear();
    _guardarHistorial();
    notifyListeners();
  }

  // ── Sugerencias en tiempo real (tipo YouTube) ─────────────────────────────
  Future<void> actualizarSugerencias(String query) async {
    if (query.trim().length < 2) {
      sugerencias = [];
      mostrandoSugerencias = false;
      notifyListeners();
      return;
    }

    mostrandoSugerencias = true;
    sugerencias = await _repository.sugerencias(query);
    notifyListeners();
  }

  void ocultarSugerencias() {
    mostrandoSugerencias = false;
    notifyListeners();
  }

  // ── Búsqueda principal ────────────────────────────────────────────────────
  Future<void> buscar(String query, {String? filtro}) async {
    final q = query.trim();
    if (filtro != null) filtroActivo = filtro;

    ocultarSugerencias();

    if (q.isEmpty) {
      resultados = [];
      currentQuery = '';
      notifyListeners();
      return;
    }

    isLoading = true;
    currentQuery = q;
    _agregarAlHistorial(q);
    notifyListeners();

    // Delega la operación de búsqueda al caso de uso
    resultados = await _buscarContenidoUseCase(
      BuscarContenidoParams(query: q, filtro: filtroActivo),
    );

    isLoading = false;
    notifyListeners();
  }

  void cambiarFiltro(String filtro) {
    if (filtro == filtroActivo) return;
    filtroActivo = filtro;
    if (currentQuery.isNotEmpty) {
      buscar(currentQuery, filtro: filtro);
    } else {
      notifyListeners();
    }
  }

  void limpiarResultados() {
    resultados = [];
    sugerencias = [];
    currentQuery = '';
    filtroActivo = 'Todos';
    mostrandoSugerencias = false;
    notifyListeners();
  }
}
