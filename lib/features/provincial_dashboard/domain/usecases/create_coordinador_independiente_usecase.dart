import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class CreateCoordinadorIndependienteUseCase {
  final ProvincialRepository repository;

  CreateCoordinadorIndependienteUseCase(this.repository);

  Future<Either<String, void>> call({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  }) async {
    return await repository.createCoordinadorIndependiente(
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correo: correo,
    );
  }
}
