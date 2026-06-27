import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class AsignarCoordinadorUseCase {
  final ProvincialRepository repository;

  AsignarCoordinadorUseCase(this.repository);

  Future<Either<String, void>> call(String recintoId, String coordinadorId) async {
    return await repository.asignarCoordinador(recintoId, coordinadorId);
  }
}
