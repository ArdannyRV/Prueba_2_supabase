import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class UpdateCoordinadorUseCase {
  final ProvincialRepository repository;

  UpdateCoordinadorUseCase(this.repository);

  Future<Either<String, void>> call({
    required String id,
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    return await repository.updateCoordinador(
      id: id,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
    );
  }
}
