import 'package:book_l/core/infrastructure/services/bookl_service.dart';
import 'package:book_l/features/leccion/domain/models/capitulo.dart';
import 'package:book_l/features/leccion/application/ports/out/capitulo_repository.dart';

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
  Future<int> addCapitulo(Capitulo capitulo) async {
    final newId = _service.nextCapituloId();
    final nuevo = capitulo.copyWith(idCapitulo: newId);
    _service.addCapitulo(nuevo);
    return newId;
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> updateCapitulo(Capitulo capitulo) async {
    _service.updateCapitulo(capitulo);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  @override
  Future<void> deleteCapitulo(int id) async {
    _service.removeCapitulo(id);
  }
}
