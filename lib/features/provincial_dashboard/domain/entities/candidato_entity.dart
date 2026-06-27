import 'package:equatable/equatable.dart';

class CandidatoEntity extends Equatable {
  final String id;
  final String nombre;
  final String partido;
  final String cargo;
  final String? fotoUrl;

  const CandidatoEntity({
    required this.id,
    required this.nombre,
    required this.partido,
    required this.cargo,
    this.fotoUrl,
  });

  @override
  List<Object?> get props => [id, nombre, partido, cargo, fotoUrl];
}
