import 'package:flutter/material.dart';
import '../../data/repositories/busqueda_repository.dart';

class BusquedaController extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final BusquedaController _instance = BusquedaController._internal();
  factory BusquedaController() => _instance;
  BusquedaController._internal();

  final BusquedaRepository _repository = BusquedaRepository();
  
  List<Map<String, dynamic>> resultados = [];
  bool isLoading = false;
  
  String currentQuery = '';
  
  // Lista de historial de búsquedas (podría persistirse localmente)
  List<String> historialBusquedas = [
    'Matemáticas Discretas',
    'Leyes de derecho en Colombia',
    'Cálculo Diferencial',
    'Programación',
  ];

  Future<void> buscar(String query, {String filtro = 'Todas'}) async {
    if (query.trim().isEmpty) {
      resultados = [];
      notifyListeners();
      return;
    }
    
    isLoading = true;
    currentQuery = query;
    notifyListeners();

    // Guardar en historial si no está
    if (!historialBusquedas.contains(query)) {
      historialBusquedas.insert(0, query);
      if (historialBusquedas.length > 10) {
        historialBusquedas.removeLast();
      }
    }

    resultados = await _repository.buscarCursos(query, filtro: filtro);
    
    isLoading = false;
    notifyListeners();
  }

  void eliminarDelHistorial(int index) {
    historialBusquedas.removeAt(index);
    notifyListeners();
  }
  
  void limpiarResultados() {
    resultados = [];
    currentQuery = '';
    notifyListeners();
  }
}
