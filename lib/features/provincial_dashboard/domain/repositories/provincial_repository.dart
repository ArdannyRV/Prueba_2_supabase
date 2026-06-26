import 'package:dartz/dartz.dart';
import '../entities/recinto_entity.dart';

abstract class ProvincialRepository {
  Future<Either<String, List<RecintoEntity>>> getRecintos();
  
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
}
