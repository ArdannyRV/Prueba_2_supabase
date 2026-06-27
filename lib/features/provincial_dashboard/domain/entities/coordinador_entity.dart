import 'package:equatable/equatable.dart';

class CoordinadorEntity extends Equatable {
  final String id;
  final String? cedula;
  final String? nombres;
  final String? apellidos;
  final String? telefono;
  final String? correo;
  final bool? debeCambiarPass;
  final String? recintoAsignado; // nombre del recinto o null

  const CoordinadorEntity({
    required this.id,
    this.cedula,
    this.nombres,
    this.apellidos,
    this.telefono,
    this.correo,
    this.debeCambiarPass,
    this.recintoAsignado,
  });

  String get nombreCompleto => '${nombres ?? ''} ${apellidos ?? ''}'.trim();

  @override
  List<Object?> get props => [
        id,
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
        debeCambiarPass,
        recintoAsignado,
      ];
}
