import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/coordinador_entity.dart';
import '../repositories/provincial_repository.dart';

@injectable
class GetUnassignedCoordinadoresUseCase {
  final ProvincialRepository repository;

  GetUnassignedCoordinadoresUseCase(this.repository);

  Future<Either<String, List<CoordinadorEntity>>> call() async {
    return await repository.getUnassignedCoordinadores();
  }
}
