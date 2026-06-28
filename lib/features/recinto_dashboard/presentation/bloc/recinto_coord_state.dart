import '../../domain/entities/mesa_detalle_entity.dart';
import '../../domain/entities/veedor_entity.dart';

class RecintoCoordState {
  final bool isLoading;
  final String? recintoId;
  final String? recintoNombre;
  final List<MesaDetalleEntity> mesas;
  final List<VeedorEntity> veedores;
  final String? successMessage;
  final String? errorMessage;

  const RecintoCoordState({
    this.isLoading = false,
    this.recintoId,
    this.recintoNombre,
    this.mesas = const [],
    this.veedores = const [],
    this.successMessage,
    this.errorMessage,
  });

  RecintoCoordState copyWith({
    bool? isLoading,
    String? recintoId,
    String? recintoNombre,
    List<MesaDetalleEntity>? mesas,
    List<VeedorEntity>? veedores,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return RecintoCoordState(
      isLoading: isLoading ?? this.isLoading,
      recintoId: recintoId ?? this.recintoId,
      recintoNombre: recintoNombre ?? this.recintoNombre,
      mesas: mesas ?? this.mesas,
      veedores: veedores ?? this.veedores,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
