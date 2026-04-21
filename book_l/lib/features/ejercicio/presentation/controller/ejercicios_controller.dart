import 'package:flutter/foundation.dart';
import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/ejercicio.dart';
import '../../../leccion/domain/entities/capitulo.dart';

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
}
