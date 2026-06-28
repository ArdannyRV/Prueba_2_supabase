import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/veedor_remote_data_source.dart';
import 'veedor_event.dart';
import 'veedor_state.dart';

class VeedorBloc extends Bloc<VeedorEvent, VeedorState> {
  final VeedorRemoteDataSource dataSource;

  VeedorBloc(this.dataSource) : super(const VeedorState()) {
    on<InitVeedorEvent>(_onInitVeedor);
    on<FetchMisActasEvent>(_onFetchMisActas);
    on<RegistrarActaEvent>(_onRegistrarActa);
    on<CorregirActaVeedorEvent>(_onCorregirActa);
  }

  Future<void> _onInitVeedor(InitVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final mesas = await dataSource.getMisAsignadas();
      emit(state.copyWith(
        isLoading: false,
        mesas: mesas,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchMisActas(FetchMisActasEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final actas = await dataSource.getMisActas(event.mesaId);
      emit(state.copyWith(
        isLoading: false,
        actasActuales: actas,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRegistrarActa(RegistrarActaEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      await dataSource.registrarActa(
        mesaId: event.mesaId,
        dignidad: event.dignidad,
        votosBlancos: event.votosBlancos,
        votosNulos: event.votosNulos,
        totalSufragantes: event.totalSufragantes,
        fotoUrl: event.fotoUrl,
        latitud: event.latitud,
        longitud: event.longitud,
        votos: event.votos,
      );
      
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Acta registrada exitosamente',
      ));
      
      // Reload mesas to update UI state
      add(InitVeedorEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCorregirActa(CorregirActaVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      await dataSource.corregirActa(
        actaId: event.actaId,
        votosBlancos: event.votosBlancos,
        votosNulos: event.votosNulos,
        totalSufragantes: event.totalSufragantes,
        fotoUrl: event.fotoUrl,
        votos: event.votos,
      );
      
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Acta corregida exitosamente',
      ));
      
      // We don't automatically know the mesaId here to refetch, but we can re-trigger init
      add(InitVeedorEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
