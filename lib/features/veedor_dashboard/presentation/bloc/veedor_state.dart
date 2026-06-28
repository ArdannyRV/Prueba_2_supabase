import '../../domain/entities/mesa_veedor_entity.dart';

class VeedorState {
  final bool isLoading;
  final List<MesaVeedorEntity> mesas;
  final List<Map<String, dynamic>> actasActuales; // para mis_actas_page
  final String? successMessage;
  final String? errorMessage;

  const VeedorState({
    this.isLoading = false,
    this.mesas = const [],
    this.actasActuales = const [],
    this.successMessage,
    this.errorMessage,
  });

  VeedorState copyWith({
    bool? isLoading,
    List<MesaVeedorEntity>? mesas,
    List<Map<String, dynamic>>? actasActuales,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
  }) {
    return VeedorState(
      isLoading: isLoading ?? this.isLoading,
      mesas: mesas ?? this.mesas,
      actasActuales: actasActuales ?? this.actasActuales,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
