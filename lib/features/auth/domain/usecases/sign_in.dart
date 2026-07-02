import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignIn implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignIn(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithCedulaAndPassword(
      cedula: params.cedula,
      password: params.password,
    );
  }
}

class SignInParams {
  final String cedula;
  final String password;

  SignInParams({
    required this.cedula,
    required this.password,
  });
}
