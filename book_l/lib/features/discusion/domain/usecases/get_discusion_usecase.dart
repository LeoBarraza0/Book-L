import '../entities/discusion.dart';
import '../repositories/discusion_repository.dart';

class GetDiscusionParams {
  final int? idCurso;
  final int? idLeccion;
  GetDiscusionParams({this.idCurso, this.idLeccion});
}

class GetDiscusionUseCase {
  final DiscusionRepository repository;
  GetDiscusionUseCase(this.repository);

  Future<Discusion> call(GetDiscusionParams params) async {
    // En Book-L la obtención de discusión es inmediata vía repo
    return repository.obtenerOCrearDiscusion(
      idCurso: params.idCurso,
      idLeccion: params.idLeccion,
    );
  }
}
