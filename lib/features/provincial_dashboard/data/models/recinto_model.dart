import '../../domain/entities/recinto_entity.dart';
import 'mesa_model.dart';

class RecintoModel extends RecintoEntity {
  const RecintoModel({
    required super.id,
    required super.nombre,
    required super.parroquia,
    required super.canton,
    super.provincia,
    super.coordinadorId,
    super.coordinadorNombre,
    required super.mesas,
  });

  factory RecintoModel.fromJson(Map<String, dynamic> json) {
    List<MesaModel> mesas = [];
    if (json['mesas'] != null) {
      mesas = (json['mesas'] as List)
          .map((m) => MesaModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return RecintoModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      parroquia: json['parroquia'] as String,
      canton: json['canton'] as String,
      provincia: json['provincia'] as String?,
      coordinadorId: json['coordinador_id'] as String?,
      coordinadorNombre: json['coordinador'] != null 
          ? '${json['coordinador']['nombres'] ?? ''} ${json['coordinador']['apellidos'] ?? ''}'.trim()
          : null,
      mesas: mesas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'parroquia': parroquia,
      'canton': canton,
      'provincia': provincia,
      'coordinador_id': coordinadorId,
    };
  }
}
