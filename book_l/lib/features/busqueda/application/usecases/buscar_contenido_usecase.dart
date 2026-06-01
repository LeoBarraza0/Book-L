import '../../domain/models/resultado_busqueda.dart';
import '../ports/out/busqueda_repository.dart';

class BuscarContenidoParams {
  final String query;
  final String filtro;
  BuscarContenidoParams({required this.query, this.filtro = 'Todos'});
}

/// Caso de uso: Buscar Contenido.
/// Permite realizar búsquedas avanzadas con filtros.
class BuscarContenidoUseCase {
  final BusquedaRepository repository;
  BuscarContenidoUseCase(this.repository);

  Future<List<ResultadoBusqueda>> call(BuscarContenidoParams params) =>
      repository.buscar(params.query, filtro: params.filtro);
}
