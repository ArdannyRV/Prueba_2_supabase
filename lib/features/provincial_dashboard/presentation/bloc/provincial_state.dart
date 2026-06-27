import 'package:equatable/equatable.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/coordinador_entity.dart';

class ProvincialState extends Equatable {
  final List<RecintoEntity> recintos;
  final List<CoordinadorEntity> coordinadores; // All coordinadores
  final List<CoordinadorEntity> unassignedCoordinadores;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const ProvincialState({
    this.recintos = const [],
    this.coordinadores = const [],
    this.unassignedCoordinadores = const [],
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ProvincialState copyWith({
    List<RecintoEntity>? recintos,
    List<CoordinadorEntity>? coordinadores,
    List<CoordinadorEntity>? unassignedCoordinadores,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ProvincialState(
      recintos: recintos ?? this.recintos,
      coordinadores: coordinadores ?? this.coordinadores,
      unassignedCoordinadores: unassignedCoordinadores ?? this.unassignedCoordinadores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        recintos,
        coordinadores,
        unassignedCoordinadores,
        isLoading,
        errorMessage,
        successMessage,
      ];
}
