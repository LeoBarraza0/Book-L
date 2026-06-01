import '../../../domain/models/capitulo.dart';

// Puerto de salida para Capítulo — solo conoce entidades de dominio.
abstract class CapituloRepository {
  Future<List<Capitulo>> getCapitulos();
  Future<Capitulo?> getCapituloById(int id);
  Future<int> addCapitulo(Capitulo capitulo);
  Future<void> updateCapitulo(Capitulo capitulo);
  Future<void> deleteCapitulo(int id);
}
