import '../../domain/entities/coordinador_entity.dart';

class CoordinadorModel extends CoordinadorEntity {
  const CoordinadorModel({
    required super.id,
    super.cedula,
    super.nombres,
    super.apellidos,
    super.telefono,
    super.correo,
    super.debeCambiarPass,
  });

  factory CoordinadorModel.fromJson(Map<String, dynamic> json) {
    return CoordinadorModel(
      id: json['id'],
      cedula: json['cedula'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      telefono: json['telefono'],
      correo: json['correo'],
      debeCambiarPass: json['debe_cambiar_pass'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'correo': correo,
      'debe_cambiar_pass': debeCambiarPass,
    };
  }
}
