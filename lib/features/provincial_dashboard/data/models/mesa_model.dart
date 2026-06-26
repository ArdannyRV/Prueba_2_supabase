import '../../domain/entities/mesa_entity.dart';

class MesaModel extends MesaEntity {
  const MesaModel({
    required super.id,
    required super.numeroMesa,
    required super.recintoId,
    super.veedorId,
    super.tieneActa = false,
    super.latitud,
    super.longitud,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    bool tieneActa = false;
    double? lat;
    double? lng;

    if (json['actas'] != null) {
      final actas = json['actas'] as List;
      if (actas.isNotEmpty) {
        tieneActa = true;
        lat = (actas.first['latitud'] as num?)?.toDouble();
        lng = (actas.first['longitud'] as num?)?.toDouble();
      }
    }

    return MesaModel(
      id: json['id'] as String,
      numeroMesa: json['numero_mesa'] as int,
      recintoId: json['recinto_id'] as String,
      veedorId: json['veedor_id'] as String?,
      tieneActa: tieneActa,
      latitud: lat,
      longitud: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero_mesa': numeroMesa,
      'recinto_id': recintoId,
      'veedor_id': veedorId,
    };
  }
}
