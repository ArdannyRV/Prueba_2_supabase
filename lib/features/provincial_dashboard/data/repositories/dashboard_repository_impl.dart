import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/resultado_voto_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<ResultadoVotoEntity>>> getResultadosPorCargo(String cargo) async {
    try {
      final result = await remoteDataSource.getResultadosPorCargo(cargo);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
