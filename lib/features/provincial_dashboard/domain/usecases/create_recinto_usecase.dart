import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@lazySingleton
class CreateRecintoUseCase {
  final ProvincialRepository repository;

  CreateRecintoUseCase(this.repository);

  Future<Either<String, void>> call({
    required String nombre,
    required String parroquia,
    required String canton,
    required int totalMesas,
  }) {
    return repository.createRecinto(
      nombre: nombre,
      parroquia: parroquia,
      canton: canton,
      totalMesas: totalMesas,
    );
  }
}
