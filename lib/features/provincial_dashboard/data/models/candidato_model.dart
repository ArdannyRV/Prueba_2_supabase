import '../../domain/entities/candidato_entity.dart';

class CandidatoModel extends CandidatoEntity {
  const CandidatoModel({
    required super.id,
    required super.nombre,
    required super.partido,
    required super.cargo,
    super.fotoUrl,
  });

  factory CandidatoModel.fromJson(Map<String, dynamic> json) {
    return CandidatoModel(
      id: json['id'],
      nombre: json['nombre'] ?? 'Desconocido',
      partido: json['partido'] ?? 'Independiente',
      cargo: json['cargo'] ?? 'Desconocido',
      fotoUrl: json['foto_url'],
    );
  }
}
