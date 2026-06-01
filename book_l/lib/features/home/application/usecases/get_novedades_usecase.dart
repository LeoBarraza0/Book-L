import '../../../../core/usecase/usecase.dart';
import '../../infrastructure/adapters/out/repositories/home_repository_impl.dart';
import '../../domain/models/novedad.dart';

class GetNovedadesUseCase implements UseCase<List<Novedad>, NoParams> {
  final _repo = HomeRepositoryImpl();

  @override
  Future<List<Novedad>> call(NoParams params) async {
    return await _repo.getNovedades();
  }
}
