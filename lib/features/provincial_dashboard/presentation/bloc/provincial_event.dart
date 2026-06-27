import 'package:equatable/equatable.dart';

abstract class ProvincialEvent extends Equatable {
  const ProvincialEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecintosEvent extends ProvincialEvent {
  const FetchRecintosEvent();
}

class FetchUnassignedCoordinadoresEvent extends ProvincialEvent {
  const FetchUnassignedCoordinadoresEvent();
}

class FetchAllCoordinadoresEvent extends ProvincialEvent {
  const FetchAllCoordinadoresEvent();
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

class AsignarCoordinadorEvent extends ProvincialEvent {
  final String recintoId;
  final String coordinadorId;

  const AsignarCoordinadorEvent({
    required this.recintoId,
    required this.coordinadorId,
  });

  @override
  List<Object?> get props => [recintoId, coordinadorId];
}

class DeleteRecintoEvent extends ProvincialEvent {
  final String recintoId;

  const DeleteRecintoEvent({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}

class DeleteCoordinadorEvent extends ProvincialEvent {
  final String coordinadorId;

  const DeleteCoordinadorEvent({required this.coordinadorId});

  @override
  List<Object?> get props => [coordinadorId];
}

class CreateCoordinadorIndependienteEvent extends ProvincialEvent {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String telefono;
  final String correo;

  const CreateCoordinadorIndependienteEvent({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
    required this.correo,
  });

  @override
  List<Object?> get props => [cedula, nombres, apellidos, telefono, correo];
}

class UpdateCoordinadorEvent extends ProvincialEvent {
  final String id;
  final String nombres;
  final String apellidos;
  final String telefono;

  const UpdateCoordinadorEvent({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.telefono,
  });

  @override
  List<Object?> get props => [id, nombres, apellidos, telefono];
}

class DesasignarCoordinadorEvent extends ProvincialEvent {
  final String recintoId;

  const DesasignarCoordinadorEvent({required this.recintoId});

  @override
  List<Object?> get props => [recintoId];
}
