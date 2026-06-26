import 'package:equatable/equatable.dart';
import 'mesa_entity.dart';

class RecintoEntity extends Equatable {
  final String id;
  final String nombre;
  final String parroquia;
  final String canton;
  final String? provincia;
  final String? coordinadorId;
  final List<MesaEntity> mesas;

  const RecintoEntity({
    required this.id,
    required this.nombre,
    required this.parroquia,
    required this.canton,
    this.provincia,
    this.coordinadorId,
    required this.mesas,
  });

  int get totalMesas => mesas.length;
  int get mesasConActa => mesas.where((m) => m.tieneActa).length;

  @override
  List<Object?> get props => [
        id,
        nombre,
        parroquia,
        canton,
        provincia,
        coordinadorId,
        mesas,
      ];
}
