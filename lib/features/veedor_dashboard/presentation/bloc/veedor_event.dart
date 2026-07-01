abstract class VeedorEvent {}

class InitVeedorEvent extends VeedorEvent {}

class FetchMisActasEvent extends VeedorEvent {
  final String mesaId;
  FetchMisActasEvent(this.mesaId);
}

class RegistrarActaEvent extends VeedorEvent {
  final String mesaId;
  final String dignidad;
  final String fotoLocalPath;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final double latitud;
  final double longitud;
  final List<Map<String, dynamic>> votos;

  RegistrarActaEvent({
    required this.mesaId,
    required this.dignidad,
    required this.fotoLocalPath,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.latitud,
    required this.longitud,
    required this.votos,
  });
}

class CorregirActaVeedorEvent extends VeedorEvent {
  final Map<String, dynamic> actaOriginal;
  final String actaLocalId;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final String? fotoLocalPath;
  final List<Map<String, dynamic>> votos;

  CorregirActaVeedorEvent({
    required this.actaOriginal,
    required this.actaLocalId,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    this.fotoLocalPath,
    required this.votos,
  });
}

class EliminarActaVeedorEvent extends VeedorEvent {
  final String actaLocalId;
  final String mesaId;
  final String dignidad;
  EliminarActaVeedorEvent({required this.actaLocalId, required this.mesaId, required this.dignidad});
}

class SincronizarPendientesEvent extends VeedorEvent {}

class ResolverConflictoEvent extends VeedorEvent {
  final String actaLocalId;
  final bool mantenerLocal;

  ResolverConflictoEvent({required this.actaLocalId, required this.mantenerLocal});
}
