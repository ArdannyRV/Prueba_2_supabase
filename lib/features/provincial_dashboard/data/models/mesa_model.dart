import '../../domain/entities/mesa_entity.dart';

class MesaModel extends MesaEntity {
  const MesaModel({
    required super.id,
    required super.numeroMesa,
    required super.recintoId,
    super.veedorId,
    super.veedorNombre,
    super.tieneActa = false,
    super.latitudAlcaldia,
    super.longitudAlcaldia,
    super.latitudPrefectura,
    super.longitudPrefectura,
    super.fotoUrlAlcaldia,
    super.fotoUrlPrefectura,
    super.votosBlancos,
    super.votosNulos,
    super.totalSufragantes,
    super.corregida,
    super.votosAlcaldia = const [],
    super.votosPrefectura = const [],
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    bool tieneActa = false;
    double? latitudAlcaldia, longitudAlcaldia;
    double? latitudPrefectura, longitudPrefectura;
    String? fotoUrlAlcaldia, fotoUrlPrefectura;
    int? votosBlancos, votosNulos, totalSufragantes;
    bool? corregida;
    String? veedorNombre;
    List<Map<String, dynamic>> votosAlcaldia = [];
    List<Map<String, dynamic>> votosPrefectura = [];

    if (json['perfiles'] != null) {
      final p = json['perfiles'];
      veedorNombre = '${p['nombres'] ?? ''} ${p['apellidos'] ?? ''}'.trim();
    }

    if (json['actas'] != null) {
      final actas = json['actas'] as List;
      if (actas.isNotEmpty) {
        tieneActa = true;
        final primera = actas.first;
        votosBlancos = primera['votos_blancos'];
        votosNulos = primera['votos_nulos'];
        totalSufragantes = primera['total_sufragantes'];
        corregida = primera['corregida'];

        for (final acta in actas) {
          final dignidad = acta['dignidad'] as String?;
          final foto = acta['foto_url'] as String?;
          final lat = (acta['latitud'] as num?)?.toDouble();
          final lng = (acta['longitud'] as num?)?.toDouble();

          if (dignidad == 'alcaldia') {
            fotoUrlAlcaldia = foto;
            latitudAlcaldia = lat;
            longitudAlcaldia = lng;
          } else if (dignidad == 'prefectura') {
            fotoUrlPrefectura = foto;
            latitudPrefectura = lat;
            longitudPrefectura = lng;
          }

          final List votos = acta['votos_candidatos'] ?? [];
          for (final voto in votos) {
            final cand = voto['candidatos'];
            if (cand == null) continue;
            final mapVoto = {
              'candidato_id': cand['id'] ?? voto['candidato_id'],
              'nombre_candidato': cand['nombre_candidato'],
              'organizacion_politica': cand['organizacion_politica'],
              'cantidad': voto['cantidad'],
            };
            if (cand['dignidad'] == 'alcaldia') {
              votosAlcaldia.add(mapVoto);
            } else if (cand['dignidad'] == 'prefectura') {
              votosPrefectura.add(mapVoto);
            }
          }
        }
      }
    }

    return MesaModel(
      id: json['id'] as String,
      numeroMesa: json['numero_mesa'] as int,
      recintoId: json['recinto_id'] as String,
      veedorId: json['veedor_id'] as String?,
      veedorNombre: veedorNombre,
      tieneActa: tieneActa,
      latitudAlcaldia: latitudAlcaldia,
      longitudAlcaldia: longitudAlcaldia,
      latitudPrefectura: latitudPrefectura,
      longitudPrefectura: longitudPrefectura,
      fotoUrlAlcaldia: fotoUrlAlcaldia,
      fotoUrlPrefectura: fotoUrlPrefectura,
      votosBlancos: votosBlancos,
      votosNulos: votosNulos,
      totalSufragantes: totalSufragantes,
      corregida: corregida,
      votosAlcaldia: votosAlcaldia,
      votosPrefectura: votosPrefectura,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_mesa': numeroMesa,
    'recinto_id': recintoId,
    'veedor_id': veedorId,
  };
}
