import 'package:equatable/equatable.dart';

class MesaEntity extends Equatable {
  final String id;
  final int numeroMesa;
  final String recintoId;
  final String? veedorId;
  final String? veedorNombre;
  final bool tieneActa;
  final double? latitudAlcaldia;
  final double? longitudAlcaldia;
  final double? latitudPrefectura;
  final double? longitudPrefectura;
  final String? fotoUrlAlcaldia;
  final String? fotoUrlPrefectura;
  final int? votosBlancos;
  final int? votosNulos;
  final int? totalSufragantes;
  final bool? corregida;
  final List<Map<String, dynamic>> votosAlcaldia;
  final List<Map<String, dynamic>> votosPrefectura;

  const MesaEntity({
    required this.id,
    required this.numeroMesa,
    required this.recintoId,
    this.veedorId,
    this.veedorNombre,
    this.tieneActa = false,
    this.latitudAlcaldia,
    this.longitudAlcaldia,
    this.latitudPrefectura,
    this.longitudPrefectura,
    this.fotoUrlAlcaldia,
    this.fotoUrlPrefectura,
    this.votosBlancos,
    this.votosNulos,
    this.totalSufragantes,
    this.corregida,
    this.votosAlcaldia = const [],
    this.votosPrefectura = const [],
  });

  @override
  List<Object?> get props => [id, numeroMesa, recintoId, veedorId, tieneActa];
}
