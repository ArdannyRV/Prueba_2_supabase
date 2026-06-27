import 'package:dartz/dartz.dart';
import '../entities/recinto_entity.dart';
import '../entities/coordinador_entity.dart';

abstract class ProvincialRepository {
  Future<Either<String, List<RecintoEntity>>> getRecintos();
  Future<Either<String, List<CoordinadorEntity>>> getUnassignedCoordinadores();
  Future<Either<String, List<CoordinadorEntity>>> getAllCoordinadores();
  
  Future<Either<String, void>> createRecinto({
    required String nombre,
    required String parroquia,
    required String canton,
    required int totalMesas,
  });

  Future<Either<String, void>> createCoordinadorRecinto({
    required String recintoId,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  });

  Future<Either<String, void>> createCoordinadorIndependiente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  });

  Future<Either<String, void>> updateCoordinador({
    required String id,
    required String nombres,
    required String apellidos,
    required String telefono,
  });

  Future<Either<String, void>> deleteCoordinador(String coordinadorId);

  Future<Either<String, void>> asignarCoordinador(String recintoId, String coordinadorId);

  Future<Either<String, void>> deleteRecinto(String recintoId);
  Future<Either<String, void>> desasignarCoordinador(String recintoId);
}
