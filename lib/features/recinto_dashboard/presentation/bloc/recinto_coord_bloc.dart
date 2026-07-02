import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/recinto_coord_remote_data_source.dart';
import 'recinto_coord_event.dart';
import 'recinto_coord_state.dart';

class RecintoCoordBloc extends Bloc<RecintoCoordEvent, RecintoCoordState> {
  final RecintoCoordRemoteDataSource dataSource;

  RecintoCoordBloc(this.dataSource) : super(const RecintoCoordState()) {
    on<InitRecintoCoordEvent>(_onInit);
    on<FetchMesasEvent>(_onFetchMesas);
    on<FetchVeedoresEvent>(_onFetchVeedores);
    on<AsignarVeedorEvent>(_onAsignarVeedor);
    on<DesasignarVeedorEvent>(_onDesasignarVeedor);
    on<CrearVeedorEvent>(_onCrearVeedor);
    on<ActualizarVeedorEvent>(_onActualizarVeedor);
    on<EliminarVeedorEvent>(_onEliminarVeedor);
    on<CorregirActaEvent>(_onCorregirActa);
  }

  Future<void> _onInit(InitRecintoCoordEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final recintoId = await dataSource.getRecintoId();
      final recintoNombre = await dataSource.getRecintoNombre();
      emit(state.copyWith(recintoId: recintoId, recintoNombre: recintoNombre, isLoading: false));
      
      add(const FetchMesasEvent());
      add(const FetchVeedoresEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchMesas(FetchMesasEvent event, Emitter<RecintoCoordState> emit) async {
    if (state.recintoId == null) return;
    
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final mesas = await dataSource.getMesas(state.recintoId!);
      emit(state.copyWith(mesas: mesas, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onFetchVeedores(FetchVeedoresEvent event, Emitter<RecintoCoordState> emit) async {
    if (state.recintoId == null) return;
    
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final veedores = await dataSource.getTodosVeedores(state.recintoId!);
      emit(state.copyWith(veedores: veedores, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAsignarVeedor(AsignarVeedorEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await dataSource.asignarVeedor(event.mesaId, event.veedorId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Veedor asignado correctamente',
      ));
      add(const FetchMesasEvent());
      add(const FetchVeedoresEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDesasignarVeedor(DesasignarVeedorEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await dataSource.desasignarVeedor(event.mesaId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Veedor desasignado correctamente',
      ));
      add(const FetchMesasEvent());
      add(const FetchVeedoresEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCrearVeedor(CrearVeedorEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await dataSource.crearVeedor(
        cedula: event.cedula,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
        correo: event.correo,
        recintoId: event.recintoId,
        coordinadorId: event.coordinadorId,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Veedor creado exitosamente',
      ));
      add(const FetchVeedoresEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onActualizarVeedor(ActualizarVeedorEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await dataSource.actualizarVeedor(
        id: event.id,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
      );
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Veedor actualizado correctamente',
      ));
      add(const FetchVeedoresEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onEliminarVeedor(EliminarVeedorEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      await dataSource.eliminarVeedor(event.veedorId);
      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Veedor eliminado',
      ));
      add(const FetchVeedoresEvent());
      add(const FetchMesasEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onCorregirActa(CorregirActaEvent event, Emitter<RecintoCoordState> emit) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
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
        successMessage: 'Acta corregida correctamente',
      ));
      add(const FetchMesasEvent());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
