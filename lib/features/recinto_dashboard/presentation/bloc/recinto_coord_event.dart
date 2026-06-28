abstract class RecintoCoordEvent {
  const RecintoCoordEvent();
}

class InitRecintoCoordEvent extends RecintoCoordEvent {
  const InitRecintoCoordEvent();
}

class FetchMesasEvent extends RecintoCoordEvent {
  const FetchMesasEvent();
}

class FetchVeedoresEvent extends RecintoCoordEvent {
  const FetchVeedoresEvent();
}

class AsignarVeedorEvent extends RecintoCoordEvent {
  final String mesaId;
  final String veedorId;
  const AsignarVeedorEvent({required this.mesaId, required this.veedorId});
}

class DesasignarVeedorEvent extends RecintoCoordEvent {
  final String mesaId;
  const DesasignarVeedorEvent({required this.mesaId});
}

class CrearVeedorEvent extends RecintoCoordEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;

  const CrearVeedorEvent({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
  });
}

class EliminarVeedorEvent extends RecintoCoordEvent {
  final String veedorId;
  const EliminarVeedorEvent({required this.veedorId});
}

class CorregirActaEvent extends RecintoCoordEvent {
  final String actaId;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final String? fotoUrl;
  final List<Map<String, dynamic>> votos;

  const CorregirActaEvent({
    required this.actaId,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    this.fotoUrl,
    required this.votos,
  });
}

class ActualizarVeedorEvent extends RecintoCoordEvent {
  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;

  const ActualizarVeedorEvent({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
  });
}
