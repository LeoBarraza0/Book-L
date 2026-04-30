import 'package:flutter/foundation.dart';
import '../../domain/entities/ejercicio.dart';
import '../../domain/entities/pregunta.dart';
import '../../domain/entities/opcion.dart';
import '../../data/repositories/ejercicio_repository_impl.dart';

/// Controlador singleton para la gestión de ejercicios.
/// Orquesta las operaciones CRUD delegando al repositorio.
class EjerciciosController extends ChangeNotifier {
  static final EjerciciosController _instance = EjerciciosController._internal();
  factory EjerciciosController() => _instance;
  EjerciciosController._internal();

  /// Repositorio que encapsula el acceso a datos
  final _repo = EjercicioRepositoryImpl();

  List<Ejercicio> _allEjercicios = [];
  List<Ejercicio> get filteredEjercicios => _getFiltered();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  // Categorías de ejercicios
  static const List<TipoEjercicio> tiposTeoricos = [
    TipoEjercicio.multipleChoice,
    TipoEjercicio.trueFalse,
    TipoEjercicio.respuestaCorta,
  ];

  static const List<TipoEjercicio> tiposPracticos = [
    TipoEjercicio.ordenar,
    TipoEjercicio.rellenar,
  ];

  String? _categoriaActual;
  String? get categoriaActual => _categoriaActual;

  /// Retorna los filtros activos según la categoría seleccionada
  List<String> get filtrosActivos {
    final base = ['Todos'];
    if (_categoriaActual == 'Teórico') {
      base.addAll(tiposTeoricos.map((t) => t.displayName));
    } else if (_categoriaActual == 'Práctico') {
      base.addAll(tiposPracticos.map((t) => t.displayName));
    } else {
      base.addAll(TipoEjercicio.values.map((t) => t.displayName));
    }
    return base;
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  /// Carga los ejercicios de una lección obteniendo sus capítulos
  void loadEjercicios(int idLeccion) {
    final capitulosIds = _repo.getCapituloIdsByLeccion(idLeccion);
    _allEjercicios = _repo.getEjerciciosByCapitulos(capitulosIds);
    _searchQuery = '';
    _selectedFilterIndex = 0;
    notifyListeners();
  }

  /// Retorna los tipos de ejercicio que existen para una lección
  List<TipoEjercicio> tiposDisponibles(int idLeccion) {
    final capitulosIds = _repo.getCapituloIdsByLeccion(idLeccion);
    final ejerciciosLeccion = _repo.getEjerciciosByCapitulos(capitulosIds);
    final tipos = ejerciciosLeccion.map((e) => e.tipo).toSet().toList();
    tipos.sort((a, b) => a.index.compareTo(b.index));
    return tipos;
  }

  /// Verifica si una lección tiene ejercicios de cierta categoría
  bool tieneCategoria(int idLeccion, String categoria) {
    final capitulosIds = _repo.getCapituloIdsByLeccion(idLeccion);
    final ejercicios = _repo.getEjerciciosByCapitulos(capitulosIds);
    if (categoria == 'Teórico') {
      return ejercicios.any((e) => tiposTeoricos.contains(e.tipo));
    } else {
      return ejercicios.any((e) => tiposPracticos.contains(e.tipo));
    }
  }

  /// Retorna la cantidad de ejercicios de una categoría para una lección
  int getCountByCategoria(int idLeccion, String categoria) {
    final capitulosIds = _repo.getCapituloIdsByLeccion(idLeccion);
    final ejercicios = _repo.getEjerciciosByCapitulos(capitulosIds);
    if (categoria == 'Teórico') {
      return ejercicios.where((e) => tiposTeoricos.contains(e.tipo)).length;
    } else {
      return ejercicios.where((e) => tiposPracticos.contains(e.tipo)).length;
    }
  }

  /// Retorna IDs de ejercicios de un capítulo específico
  List<int> getExerciseIdsByCapitulo(int idCapitulo) {
    return _repo.getExerciseIdsByCapitulo(idCapitulo);
  }

  void setCategoriaFiltro(String? categoria) {
    _categoriaActual = categoria;
    _selectedFilterIndex = 0;
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  /// Crea un ejercicio completo con sus preguntas y opciones.
  /// Retorna el ID del ejercicio creado.
  int crearEjercicioCompleto({
    required int idCapitulo,
    required TipoEjercicio tipo,
    required String titulo,
    required String descripcion,
    required List<PreguntaInput> preguntasInput,
  }) {
    final idEjercicio = _repo.nextEjercicioId();
    final List<Pregunta> preguntasFinales = [];
    final List<Opcion> opcionesFinales = [];

    for (final pi in preguntasInput) {
      final idPregunta = _repo.nextPreguntaId();
      final List<Opcion> opcionesPregunta = [];

      for (final oi in pi.opciones) {
        final idOpcion = _repo.nextOpcionId();
        final opcion = Opcion(
          idOpcion: idOpcion,
          idPreguntaFk: idPregunta,
          contenido: oi.contenido,
          correcta: oi.correcta,
        );
        opcionesPregunta.add(opcion);
        opcionesFinales.add(opcion);
      }

      final pregunta = Pregunta(
        idPregunta: idPregunta,
        idEjercicioFk: idEjercicio,
        contenido: pi.contenido,
        explicacion: pi.explicacion,
        opciones: opcionesPregunta,
      );
      preguntasFinales.add(pregunta);
    }

    final ejercicio = Ejercicio(
      idEjercicio: idEjercicio,
      idCapitulo: idCapitulo,
      tipo: tipo,
      titulo: titulo,
      descripcion: descripcion,
      preguntas: preguntasFinales,
    );

    // Delegar persistencia al repositorio
    _repo.addEjercicio(ejercicio, preguntasFinales, opcionesFinales);
    notifyListeners();
    return idEjercicio;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  /// Elimina un ejercicio y lo remueve de la lista local
  void eliminarEjercicio(int idEjercicio) {
    _repo.removeEjercicio(idEjercicio);
    _allEjercicios.removeWhere((e) => e.idEjercicio == idEjercicio);
    notifyListeners();
  }

  // ── Filtros ────────────────────────────────────────────────────────────────

  void updateQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setFilter(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  /// Aplica filtros de categoría, tipo y búsqueda textual
  List<Ejercicio> _getFiltered() {
    List<Ejercicio> current = _allEjercicios;

    // Filtro por categoría general
    if (_categoriaActual == 'Teórico') {
      current = current.where((e) => tiposTeoricos.contains(e.tipo)).toList();
    } else if (_categoriaActual == 'Práctico') {
      current = current.where((e) => tiposPracticos.contains(e.tipo)).toList();
    }

    // Filtro por tipo específico
    if (_selectedFilterIndex > 0) {
      TipoEjercicio selectedTipo;
      if (_categoriaActual == 'Teórico') {
        selectedTipo = tiposTeoricos[_selectedFilterIndex - 1];
      } else if (_categoriaActual == 'Práctico') {
        selectedTipo = tiposPracticos[_selectedFilterIndex - 1];
      } else {
        selectedTipo = TipoEjercicio.values[_selectedFilterIndex - 1];
      }
      current = current.where((e) => e.tipo == selectedTipo).toList();
    }

    // Filtro por texto
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      current = current
          .where((e) =>
              e.titulo.toLowerCase().contains(q) ||
              e.descripcion.toLowerCase().contains(q))
          .toList();
    }

    return current;
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton — no destruir para mantener el estado durante la navegación
  }
}

/// Modelo auxiliar para input de preguntas durante la creación
class PreguntaInput {
  final String contenido;
  final String? explicacion;
  final List<OpcionInput> opciones;

  const PreguntaInput({
    required this.contenido,
    this.explicacion,
    this.opciones = const [],
  });
}

/// Modelo auxiliar para input de opciones durante la creación
class OpcionInput {
  final String contenido;
  final bool correcta;

  const OpcionInput({
    required this.contenido,
    this.correcta = false,
  });
}
