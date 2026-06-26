import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/recinto_entity.dart';
import '../repositories/provincial_repository.dart';

@lazySingleton
class GetRecintosUseCase {
  final ProvincialRepository repository;

  GetRecintosUseCase(this.repository);

  Future<Either<String, List<RecintoEntity>>> call() {
    return repository.getRecintos();
  }
}
