import '../../../domain/models/resultado_busqueda.dart';

// Puerto de salida (Outbound Port) — contrato de búsqueda.
abstract class BusquedaRepository {
  /// Busca resultados según el query y el filtro aplicado.
  Future<List<ResultadoBusqueda>> buscar(
    String query, {
    String filtro = 'Todos',
  });

  /// Sugerencias autocompletado (máx. 6)
  Future<List<String>> sugerencias(String query);

  /// Carga el historial de búsquedas del usuario persistido
  Future<List<String>> cargarHistorial(int userId);

  /// Guarda el historial de búsquedas del usuario
  Future<void> guardarHistorial(int userId, List<String> historial);
}
