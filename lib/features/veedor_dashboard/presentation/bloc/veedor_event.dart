abstract class VeedorEvent {}

class InitVeedorEvent extends VeedorEvent {}

class FetchMisActasEvent extends VeedorEvent {
  final String mesaId;
  FetchMisActasEvent(this.mesaId);
}

class RegistrarActaEvent extends VeedorEvent {
  final String mesaId;
  final String dignidad;
  final String fotoUrl;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final double latitud;
  final double longitud;
  final List<Map<String, dynamic>> votos;

  RegistrarActaEvent({
    required this.mesaId,
    required this.dignidad,
    required this.fotoUrl,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.latitud,
    required this.longitud,
    required this.votos,
  });
}

class CorregirActaVeedorEvent extends VeedorEvent {
  final String actaId;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final String? fotoUrl;
  final List<Map<String, dynamic>> votos;

  CorregirActaVeedorEvent({
    required this.actaId,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    this.fotoUrl,
    required this.votos,
  });
}

class EliminarActaVeedorEvent extends VeedorEvent {
  final String actaId;
  final String mesaId;
  EliminarActaVeedorEvent({required this.actaId, required this.mesaId});
}
