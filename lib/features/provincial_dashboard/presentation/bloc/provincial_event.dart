import 'package:equatable/equatable.dart';

abstract class ProvincialEvent extends Equatable {
  const ProvincialEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecintosEvent extends ProvincialEvent {
  const FetchRecintosEvent();
}

class CreateRecintoEvent extends ProvincialEvent {
  final String nombre;
  final String parroquia;
  final String canton;
  final int totalMesas;

  const CreateRecintoEvent({
    required this.nombre,
    required this.parroquia,
    required this.canton,
    required this.totalMesas,
  });

  @override
  List<Object?> get props => [nombre, parroquia, canton, totalMesas];
}

class CreateCoordinadorEvent extends ProvincialEvent {
  final String recintoId;
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;

  const CreateCoordinadorEvent({
    required this.recintoId,
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
  });

  @override
  List<Object?> get props => [
        recintoId,
        cedula,
        nombres,
        apellidos,
        telefono,
        correo,
      ];
}
