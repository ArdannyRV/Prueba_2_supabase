import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/veedor_repository.dart';
import 'veedor_event.dart';
import 'veedor_state.dart';

@injectable
class VeedorBloc extends Bloc<VeedorEvent, VeedorState> {
  final VeedorRepository repository;

  VeedorBloc(this.repository) : super(const VeedorState()) {
    on<InitVeedorEvent>(_onInitVeedor);
    on<FetchMisActasEvent>(_onFetchMisActas);
    on<RegistrarActaEvent>(_onRegistrarActa);
    on<CorregirActaVeedorEvent>(_onCorregirActa);
    on<EliminarActaVeedorEvent>(_onEliminarActa);
    on<SincronizarPendientesEvent>(_onSincronizarPendientes);
    on<ResolverConflictoEvent>(_onResolverConflicto);
  }

  Future<void> _onInitVeedor(InitVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      final mesas = await repository.getMisAsignadas();
      final conflictos = await repository.getActasEnConflicto();
      
      // Cachear candidatos de forma silenciosa para que estén disponibles offline
      try {
        await repository.getCandidatos('alcaldia');
        await repository.getCandidatos('prefectura');
      } catch (_) {
        // Ignorar errores aquí. Si no hay conexión y no hay caché, fallará en registro_acta_page
      }

      emit(state.copyWith(
        isLoading: false,
        mesas: mesas,
        actasEnConflicto: conflictos,
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
      final actas = await repository.getMisActas(event.mesaId);
      final conflictos = await repository.getActasEnConflicto();
      emit(state.copyWith(
        isLoading: false,
        actasActuales: actas,
        actasEnConflicto: conflictos,
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
      await repository.registrarActa(
        mesaId: event.mesaId,
        dignidad: event.dignidad,
        votosBlancos: event.votosBlancos,
        votosNulos: event.votosNulos,
        totalSufragantes: event.totalSufragantes,
        fotoLocalPath: event.fotoLocalPath,
        latitud: event.latitud,
        longitud: event.longitud,
        votos: event.votos,
      );
      
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Acta guardada exitosamente',
      ));
      
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
      await repository.corregirActa(
        actaOriginal: event.actaOriginal,
        actaLocalId: event.actaLocalId,
        votosBlancos: event.votosBlancos,
        votosNulos: event.votosNulos,
        totalSufragantes: event.totalSufragantes,
        fotoLocalPath: event.fotoLocalPath,
        votos: event.votos,
      );
      
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Acta actualizada exitosamente',
      ));
      
      add(InitVeedorEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onEliminarActa(EliminarActaVeedorEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      await repository.eliminarActa(
        actaLocalId: event.actaLocalId,
        mesaId: event.mesaId,
        dignidad: event.dignidad,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Acta eliminada exitosamente',
      ));
      add(InitVeedorEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
  
  Future<void> _onSincronizarPendientes(SincronizarPendientesEvent event, Emitter<VeedorState> emit) async {
    // Si queremos disparar un sync manual
    // syncService.syncPendingData() ya maneja el estado;
    // Esto lo usaremos si inyectamos syncService aquí o lo manejamos desde otro lado.
    // Para simplificar, la UI puede escuchar al SyncService directamente o el repositorio lo maneja.
  }
  
  Future<void> _onResolverConflicto(ResolverConflictoEvent event, Emitter<VeedorState> emit) async {
    emit(state.copyWith(isLoading: true, clearSuccess: true, clearError: true));
    try {
      await repository.resolverConflicto(
        actaLocalId: event.actaLocalId,
        mantenerLocal: event.mantenerLocal,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Conflicto resuelto exitosamente',
      ));
      add(InitVeedorEvent()); // Refrescar lista de conflictos y mesas
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
