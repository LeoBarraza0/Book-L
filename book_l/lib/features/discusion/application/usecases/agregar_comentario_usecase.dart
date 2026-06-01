import '../../../../core/usecase/usecase.dart';
import '../../domain/models/comentario.dart';
import '../ports/out/discusion_repository.dart';
import 'get_discusion_usecase.dart';

class AgregarComentarioParams {
  final int idDiscusion;
  final int idUsuario;
  final String contenido;
  final int? idPadre;

  AgregarComentarioParams({
    required this.idDiscusion,
    required this.idUsuario,
    required this.contenido,
    this.idPadre,
  });
}

class AgregarComentarioUseCase implements UMLExtend<GetDiscusionUseCase> {
  final DiscusionRepository repository;

  @override
  final GetDiscusionUseCase baseUseCase;

  AgregarComentarioUseCase(this.repository, this.baseUseCase);

  @override
  bool shouldExtend(dynamic context) {
    // Retorna true si hay un contexto de discusión cargado
    return context != null;
  }

  Future<Comentario> call(AgregarComentarioParams params) async {
    return repository.agregarComentario(
      idDiscusion: params.idDiscusion,
      idUsuario: params.idUsuario,
      contenido: params.contenido,
      idPadre: params.idPadre,
    );
  }
}
