import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class DeleteCoordinadorUseCase {
  final ProvincialRepository repository;

  DeleteCoordinadorUseCase(this.repository);

  Future<Either<String, void>> call(String coordinadorId) async {
    return await repository.deleteCoordinador(coordinadorId);
  }
}
