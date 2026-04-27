import 'package:flutter/foundation.dart';
import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/ejercicio.dart';
import '../../domain/entities/pregunta.dart';
import '../../domain/entities/opcion.dart';

class EjerciciosController extends ChangeNotifier {
  static final EjerciciosController _instance = EjerciciosController._internal();
  factory EjerciciosController() => _instance;
  EjerciciosController._internal();

  final BooklService _service = BooklService();

  List<Ejercicio> _allEjercicios = [];
  List<Ejercicio> get filteredEjercicios => _getFiltered();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  // Filtros: 0: Todos, y luego los valores del enum TipoEjercicio en orden
  final List<String> filtros = [
    'Todos',
    TipoEjercicio.multipleChoice.displayName,
    TipoEjercicio.trueFalse.displayName,
    TipoEjercicio.ordenar.displayName,
    TipoEjercicio.rellenar.displayName,
    TipoEjercicio.respuestaCorta.displayName,
  ];

  // ── READ ───────────────────────────────────────────────────────────────────

  void loadEjercicios(int idLeccion) {
    // 1. Obtener capitulos de la lección
    final capitulosLeccion = _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .map((c) => c.idCapitulo)
        .toSet();

    // 2. Obtener ejercicios de esos capítulos
    _allEjercicios = _service.ejercicios
        .where((e) => capitulosLeccion.contains(e.idCapitulo))
        .toList();
    
    _searchQuery = '';
    _selectedFilterIndex = 0;
    notifyListeners();
  }

  /// Retorna los tipos de ejercicio que existen para una lección.
  List<TipoEjercicio> tiposDisponibles(int idLeccion) {
    final capitulosLeccion = _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .map((c) => c.idCapitulo)
        .toSet();

    final ejerciciosLeccion = _service.ejercicios
        .where((e) => capitulosLeccion.contains(e.idCapitulo))
        .toList();

    final tipos = ejerciciosLeccion.map((e) => e.tipo).toSet().toList();
    // Ordenar según el enum
    tipos.sort((a, b) => a.index.compareTo(b.index));
    return tipos;
  }

  /// Retorna ejercicios de una lección filtrados por tipo.
  List<Ejercicio> ejerciciosPorTipo(int idLeccion, TipoEjercicio tipo) {
    final capitulosLeccion = _service.capitulos
        .where((c) => c.idLeccion == idLeccion)
        .map((c) => c.idCapitulo)
        .toSet();

    return _service.ejercicios
        .where((e) => capitulosLeccion.contains(e.idCapitulo) && e.tipo == tipo)
        .toList();
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
    final idEjercicio = _service.nextEjercicioId();

    // Crear preguntas y opciones
    final List<Pregunta> preguntasFinales = [];
    for (final pi in preguntasInput) {
      final idPregunta = _service.nextPreguntaId();
      
      final List<Opcion> opcionesFinales = [];
      for (final oi in pi.opciones) {
        final idOpcion = _service.nextOpcionId();
        final opcion = Opcion(
          idOpcion: idOpcion,
          idPreguntaFk: idPregunta,
          contenido: oi.contenido,
          correcta: oi.correcta,
        );
        opcionesFinales.add(opcion);
        _service.opciones.add(opcion);
      }

      final pregunta = Pregunta(
        idPregunta: idPregunta,
        idEjercicioFk: idEjercicio,
        contenido: pi.contenido,
        explicacion: pi.explicacion,
        opciones: opcionesFinales,
      );
      preguntasFinales.add(pregunta);
      _service.preguntas.add(pregunta);
    }

    final ejercicio = Ejercicio(
      idEjercicio: idEjercicio,
      idCapitulo: idCapitulo,
      tipo: tipo,
      titulo: titulo,
      descripcion: descripcion,
      preguntas: preguntasFinales,
    );

    _service.addEjercicio(ejercicio);
    notifyListeners();
    return idEjercicio;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  void eliminarEjercicio(int idEjercicio) {
    _service.removeEjercicio(idEjercicio);
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

  List<Ejercicio> _getFiltered() {
    List<Ejercicio> current = _allEjercicios;

    // Filtro por tipo
    if (_selectedFilterIndex > 0) {
      final selectedTipo = TipoEjercicio.values[_selectedFilterIndex - 1];
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
  void dispose() {
    // Singleton — no destruir
  }
}

/// Modelo auxiliar para input de preguntas durante la creación.
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

/// Modelo auxiliar para input de opciones durante la creación.
class OpcionInput {
  final String contenido;
  final bool correcta;

  const OpcionInput({
    required this.contenido,
    this.correcta = false,
  });
}
