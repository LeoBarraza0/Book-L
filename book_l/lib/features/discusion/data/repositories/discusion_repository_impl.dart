import '../../domain/entities/discusion.dart';
import '../../domain/entities/comentario.dart';
import '../../domain/repositories/discusion_repository.dart';
import '../../../../core/services/bookl_service.dart';

class DiscusionRepositoryImpl implements DiscusionRepository {
  final BooklService _service = BooklService();

  @override
  Discusion obtenerOCrearDiscusion({int? idCurso, int? idLeccion}) {
    // Buscar discusión existente
    final existing = _service.discusiones.firstWhere(
      (d) =>
          (idCurso != null && d.idCursoFk == idCurso) ||
          (idLeccion != null && d.idLeccionFk == idLeccion),
      orElse: () {
        // Crear nueva discusión
        final newId = (_service.discusiones.isEmpty)
            ? 1
            : _service.discusiones
                    .map((d) => d.idDiscusion)
                    .reduce((a, b) => a > b ? a : b) +
                1;
        final nueva = Discusion(
          idDiscusion: newId,
          idCursoFk: idCurso,
          idLeccionFk: idLeccion,
        );
        _service.addDiscusion(nueva);
        return nueva;
      },
    );
    return existing;
  }

  @override
  List<Comentario> getComentariosRaiz(int idDiscusion) {
    return _service.comentarios
        .where((c) => c.idDiscusionFk == idDiscusion && c.idPadre == null)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  List<Comentario> getRespuestas(int idComentarioPadre) {
    return _service.comentarios
        .where((c) => c.idPadre == idComentarioPadre)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Comentario agregarComentario({
    required int idDiscusion,
    required int idUsuario,
    required String contenido,
    int? idPadre,
  }) {
    final newId = (_service.comentarios.isEmpty)
        ? 1
        : _service.comentarios
                .map((c) => c.idComentario)
                .reduce((a, b) => a > b ? a : b) +
            1;

    final nuevo = Comentario(
      idComentario: newId,
      idDiscusionFk: idDiscusion,
      idUsuarioFk: idUsuario,
      contenido: contenido,
      idPadre: idPadre,
      createdAt: DateTime.now(),
    );
    _service.addComentario(nuevo);
    return nuevo;
  }

  /// Todos los comentarios, para inicializar conteos de likes
  List<Comentario> getAllComentarios() => List.unmodifiable(_service.comentarios);
}
