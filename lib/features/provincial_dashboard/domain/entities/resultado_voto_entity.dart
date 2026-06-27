import 'package:equatable/equatable.dart';
import 'candidato_entity.dart';

class ResultadoVotoEntity extends Equatable {
  final CandidatoEntity candidato;
  final int totalVotos;

  const ResultadoVotoEntity({
    required this.candidato,
    required this.totalVotos,
  });

  @override
  List<Object?> get props => [candidato, totalVotos];
}
