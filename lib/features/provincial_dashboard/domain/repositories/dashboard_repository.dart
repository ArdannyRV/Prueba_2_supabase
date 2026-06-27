import 'package:dartz/dartz.dart';
import '../entities/resultado_voto_entity.dart';

abstract class DashboardRepository {
  Future<Either<String, List<ResultadoVotoEntity>>> getResultadosPorCargo(String cargo);
}
