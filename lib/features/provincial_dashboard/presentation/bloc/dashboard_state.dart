import 'package:equatable/equatable.dart';
import '../../domain/entities/resultado_voto_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ResultadoVotoEntity> resultadosAlcalde;
  final List<ResultadoVotoEntity> resultadosPrefecto;

  const DashboardLoaded({
    required this.resultadosAlcalde,
    required this.resultadosPrefecto,
  });

  @override
  List<Object> get props => [resultadosAlcalde, resultadosPrefecto];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
