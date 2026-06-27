import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class DesasignarCoordinadorUseCase {
  final ProvincialRepository repository;

  DesasignarCoordinadorUseCase(this.repository);

  Future<Either<String, void>> call(String recintoId) async {
    return await repository.desasignarCoordinador(recintoId);
  }
}
