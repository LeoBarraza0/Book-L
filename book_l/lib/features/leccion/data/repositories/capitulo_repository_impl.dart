import '../../../../core/services/bookl_service.dart';
import '../../domain/entities/capitulo.dart';
import '../../domain/repositories/capitulo_repository.dart';

class CapituloRepositoryImpl implements CapituloRepository {
  final BooklService _service;

  CapituloRepositoryImpl(this._service);

  // ── READ ───────────────────────────────────────────────────────────────────

  @override
  Future<List<Capitulo>> getCapitulos() async {
    return List.unmodifiable(_service.capitulos);
  }

  @override
  Future<Capitulo?> getCapituloById(int id) async {
    try {
      return _service.capitulos.firstWhere((c) => c.idCapitulo == id);
    } catch (_) {
      return null;
    }
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> addCapitulo(Capitulo capitulo) async {
    final nuevo = capitulo.copyWith(idCapitulo: _service.nextCapituloId());
    _service.capitulos.add(nuevo);
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCapitulo(Capitulo capitulo) async {
    final index = _service.capitulos
        .indexWhere((c) => c.idCapitulo == capitulo.idCapitulo);
    if (index != -1) _service.capitulos[index] = capitulo;
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCapitulo(int id) async {
    _service.capitulos.removeWhere((c) => c.idCapitulo == id);
  }
}
