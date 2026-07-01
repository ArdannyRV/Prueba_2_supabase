class MesaDetalleEntity {
  final String id;
  final int numeroMesa;
  final String? veedorId;
  final String? veedorNombre;
  final bool tieneActa;
  final String? actaId;
  
  // Datos del acta (null si no existe aún)
  final int? votosBlancos;
  final int? votosNulos;
  final int? totalSufragantes;
  final String? fotoUrlAlcaldia;
  final String? fotoUrlPrefectura;
  final double? latitudAlcaldia;
  final double? longitudAlcaldia;
  final double? latitudPrefectura;
  final double? longitudPrefectura;
  final bool? corregida;
  
  // Votos por dignidad
  final List<Map<String, dynamic>> votosAlcaldia; // [{nombre_candidato, organizacion_politica, cantidad}]
  final List<Map<String, dynamic>> votosPrefectura;

  const MesaDetalleEntity({
    required this.id,
    required this.numeroMesa,
    this.veedorId,
    this.veedorNombre,
    this.tieneActa = false,
    this.actaId,
    this.votosBlancos,
    this.votosNulos,
    this.totalSufragantes,
    this.fotoUrlAlcaldia,
    this.fotoUrlPrefectura,
    this.latitudAlcaldia,
    this.longitudAlcaldia,
    this.latitudPrefectura,
    this.longitudPrefectura,
    this.corregida,
    this.votosAlcaldia = const [],
    this.votosPrefectura = const [],
  });
}
