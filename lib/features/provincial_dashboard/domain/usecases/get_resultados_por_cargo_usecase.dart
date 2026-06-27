import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/resultado_voto_entity.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetResultadosPorCargoUseCase {
  final DashboardRepository repository;

  GetResultadosPorCargoUseCase(this.repository);

  Future<Either<String, List<ResultadoVotoEntity>>> call(String cargo) async {
    return await repository.getResultadosPorCargo(cargo);
  }
}
