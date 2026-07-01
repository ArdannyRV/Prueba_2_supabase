import '../../domain/entities/mesa_veedor_entity.dart';

abstract class VeedorRepository {
  Future<List<MesaVeedorEntity>> getMisAsignadas();
  
  Future<List<Map<String, dynamic>>> getMisActas(String mesaId);

  Future<List<Map<String, dynamic>>> getCandidatos(String dignidad);

  Future<void> registrarActa({
    required String mesaId,
    required String dignidad,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    required String fotoLocalPath,
    required double latitud,
    required double longitud,
    required List<Map<String, dynamic>> votos,
  });

  Future<void> corregirActa({
    required Map<String, dynamic> actaOriginal,
    required String actaLocalId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoLocalPath,
    required List<Map<String, dynamic>> votos,
  });

  Future<void> eliminarActa({
    required String actaLocalId,
    required String mesaId,
    required String dignidad,
  });

  Future<List<Map<String, dynamic>>> getActasEnConflicto();

  Future<void> resolverConflicto({
    required String actaLocalId,
    required bool mantenerLocal,
  });
}
