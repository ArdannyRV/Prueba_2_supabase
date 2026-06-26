import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/repositories/provincial_repository.dart';
import '../datasources/provincial_remote_data_source.dart';

@LazySingleton(as: ProvincialRepository)
class ProvincialRepositoryImpl implements ProvincialRepository {
  final ProvincialRemoteDataSource remoteDataSource;

  ProvincialRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<RecintoEntity>>> getRecintos() async {
    try {
      final result = await remoteDataSource.getRecintos();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createRecinto({
    required String nombre,
    required String parroquia,
    required String canton,
    required int totalMesas,
  }) async {
    try {
      await remoteDataSource.createRecinto(
        nombre: nombre,
        parroquia: parroquia,
        canton: canton,
        totalMesas: totalMesas,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> createCoordinadorRecinto({
    required String recintoId,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  }) async {
    try {
      await remoteDataSource.createCoordinadorRecinto(
        recintoId: recintoId,
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        correo: correo,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
