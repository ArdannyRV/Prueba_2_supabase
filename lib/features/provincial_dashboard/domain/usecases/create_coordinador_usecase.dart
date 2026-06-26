import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@lazySingleton
class CreateCoordinadorUseCase {
  final ProvincialRepository repository;

  CreateCoordinadorUseCase(this.repository);

  Future<Either<String, void>> call({
    required String recintoId,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  }) {
    return repository.createCoordinadorRecinto(
      recintoId: recintoId,
      cedula: cedula,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      correo: correo,
    );
  }
}
