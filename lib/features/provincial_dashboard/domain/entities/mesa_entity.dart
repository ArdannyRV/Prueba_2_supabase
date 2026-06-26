import 'package:equatable/equatable.dart';

class MesaEntity extends Equatable {
  final String id;
  final int numeroMesa;
  final String recintoId;
  final String? veedorId;
  final bool tieneActa;
  final double? latitud;
  final double? longitud;

  const MesaEntity({
    required this.id,
    required this.numeroMesa,
    required this.recintoId,
    this.veedorId,
    this.tieneActa = false,
    this.latitud,
    this.longitud,
  });

  @override
  List<Object?> get props => [id, numeroMesa, recintoId, veedorId, tieneActa, latitud, longitud];
}
