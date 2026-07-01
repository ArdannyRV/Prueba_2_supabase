class MesaDetalleEntity {
  final String id;
  final int numeroMesa;
  final String? veedorId;
  final String? veedorNombre;
  final bool tieneActa;
  final bool? corregida;

  // IDs separados por dignidad
  final String? actaIdAlcaldia;
  final String? actaIdPrefectura;

  // Totales por dignidad
  final int? votosBlaancosAlcaldia;
  final int? votosNulosAlcaldia;
  final int? totalSufragantesAlcaldia;
  final int? votosBlaancosPrefectura;
  final int? votosNulosPrefectura;
  final int? totalSufragantesPrefectura;

  // Fotos por dignidad
  final String? fotoUrlAlcaldia;
  final String? fotoUrlPrefectura;

  // GPS por dignidad
  final double? latitudAlcaldia;
  final double? longitudAlcaldia;
  final double? latitudPrefectura;
  final double? longitudPrefectura;

  // Votos por dignidad
  final List<Map<String, dynamic>> votosAlcaldia;
  final List<Map<String, dynamic>> votosPrefectura;

  const MesaDetalleEntity({
    required this.id,
    required this.numeroMesa,
    this.veedorId,
    this.veedorNombre,
    this.tieneActa = false,
    this.corregida,
    this.actaIdAlcaldia,
    this.actaIdPrefectura,
    this.votosBlaancosAlcaldia,
    this.votosNulosAlcaldia,
    this.totalSufragantesAlcaldia,
    this.votosBlaancosPrefectura,
    this.votosNulosPrefectura,
    this.totalSufragantesPrefectura,
    this.fotoUrlAlcaldia,
    this.fotoUrlPrefectura,
    this.latitudAlcaldia,
    this.longitudAlcaldia,
    this.latitudPrefectura,
    this.longitudPrefectura,
    this.votosAlcaldia = const [],
    this.votosPrefectura = const [],
  });
}
