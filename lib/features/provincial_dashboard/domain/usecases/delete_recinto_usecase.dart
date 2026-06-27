import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../repositories/provincial_repository.dart';

@injectable
class DeleteRecintoUseCase {
  final ProvincialRepository repository;

  DeleteRecintoUseCase(this.repository);

  Future<Either<String, void>> call(String recintoId) async {
    return await repository.deleteRecinto(recintoId);
  }
}
