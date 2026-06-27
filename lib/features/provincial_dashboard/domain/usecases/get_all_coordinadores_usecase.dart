import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/coordinador_entity.dart';
import '../repositories/provincial_repository.dart';

@injectable
class GetAllCoordinadoresUseCase {
  final ProvincialRepository repository;

  GetAllCoordinadoresUseCase(this.repository);

  Future<Either<String, List<CoordinadorEntity>>> call() async {
    return await repository.getAllCoordinadores();
  }
}
