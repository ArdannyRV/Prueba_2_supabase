import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_coordinador_usecase.dart';
import '../../domain/usecases/create_recinto_usecase.dart';
import '../../domain/usecases/get_recintos_usecase.dart';
import '../../domain/usecases/delete_recinto_usecase.dart';
import '../../domain/usecases/desasignar_coordinador_usecase.dart';
import '../../domain/usecases/get_unassigned_coordinadores_usecase.dart';
import '../../domain/usecases/get_all_coordinadores_usecase.dart';
import '../../domain/usecases/asignar_coordinador_usecase.dart';
import '../../domain/usecases/create_coordinador_independiente_usecase.dart';
import '../../domain/usecases/delete_coordinador_usecase.dart';
import '../../domain/usecases/update_coordinador_usecase.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

@injectable
class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintosUseCase getRecintos;
  final CreateRecintoUseCase createRecinto;
  final CreateCoordinadorUseCase createCoordinador;
  final DeleteRecintoUseCase deleteRecinto;
  final DesasignarCoordinadorUseCase desasignarCoordinador;
  final GetUnassignedCoordinadoresUseCase getUnassignedCoordinadores;
  final GetAllCoordinadoresUseCase getAllCoordinadores;
  final AsignarCoordinadorUseCase asignarCoordinador;
  final CreateCoordinadorIndependienteUseCase createCoordinadorIndependiente;
  final DeleteCoordinadorUseCase deleteCoordinador;
  final UpdateCoordinadorUseCase updateCoordinador;

  ProvincialBloc({
    required this.getRecintos,
    required this.createRecinto,
    required this.createCoordinador,
    required this.deleteRecinto,
    required this.desasignarCoordinador,
    required this.getUnassignedCoordinadores,
    required this.getAllCoordinadores,
    required this.asignarCoordinador,
    required this.createCoordinadorIndependiente,
    required this.deleteCoordinador,
    required this.updateCoordinador,
  }) : super(const ProvincialState()) {
    on<FetchRecintosEvent>(_onFetchRecintos);
    on<FetchUnassignedCoordinadoresEvent>(_onFetchUnassignedCoordinadores);
    on<FetchAllCoordinadoresEvent>(_onFetchAllCoordinadores);
    on<CreateRecintoEvent>(_onCreateRecinto);
    on<CreateCoordinadorEvent>(_onCreateCoordinador);
    on<CreateCoordinadorIndependienteEvent>(_onCreateCoordinadorIndependiente);
    on<AsignarCoordinadorEvent>(_onAsignarCoordinador);
    on<DeleteRecintoEvent>(_onDeleteRecinto);
    on<DeleteCoordinadorEvent>(_onDeleteCoordinador);
    on<DesasignarCoordinadorEvent>(_onDesasignarCoordinador);
    on<UpdateCoordinadorEvent>(_onUpdateCoordinador);
  }

  Future<void> _onFetchRecintos(
    FetchRecintosEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await getRecintos();
    result.fold(
      (error) => emit(state.copyWith(errorMessage: error, isLoading: false)),
      (recintos) => emit(state.copyWith(recintos: recintos, isLoading: false)),
    );
  }

  Future<void> _onFetchUnassignedCoordinadores(
    FetchUnassignedCoordinadoresEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    final result = await getUnassignedCoordinadores();
    result.fold(
      (error) => emit(state.copyWith(errorMessage: error)),
      (coordinadores) => emit(state.copyWith(unassignedCoordinadores: coordinadores)),
    );
  }

  Future<void> _onFetchAllCoordinadores(
    FetchAllCoordinadoresEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await getAllCoordinadores();
    result.fold(
      (error) => emit(state.copyWith(errorMessage: error, isLoading: false)),
      (coordinadores) => emit(state.copyWith(coordinadores: coordinadores, isLoading: false)),
    );
  }

  Future<void> _onCreateRecinto(
    CreateRecintoEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await createRecinto(
      nombre: event.nombre,
      parroquia: event.parroquia,
      canton: event.canton,
      totalMesas: event.totalMesas,
    );

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Recinto creado exitosamente.', isLoading: false));
        add(const FetchRecintosEvent());
      },
    );
  }

  Future<void> _onCreateCoordinador(
    CreateCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await createCoordinador(
      recintoId: event.recintoId,
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
    );

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        add(const FetchRecintosEvent());
        add(const FetchAllCoordinadoresEvent());
        emit(state.copyWith(successMessage: 'Coordinador asignado exitosamente.', isLoading: false));
      },
    );
  }

  Future<void> _onCreateCoordinadorIndependiente(
    CreateCoordinadorIndependienteEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await createCoordinadorIndependiente(
      cedula: event.cedula,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
      correo: event.correo,
    );

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Coordinador creado exitosamente.', isLoading: false));
        add(const FetchAllCoordinadoresEvent());
      },
    );
  }

  Future<void> _onAsignarCoordinador(
    AsignarCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await asignarCoordinador(event.recintoId, event.coordinadorId);

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Coordinador asignado exitosamente.', isLoading: false));
        add(const FetchRecintosEvent());
      },
    );
  }

  Future<void> _onDeleteRecinto(
    DeleteRecintoEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await deleteRecinto(event.recintoId);

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Recinto eliminado exitosamente.', isLoading: false));
        add(const FetchRecintosEvent());
      },
    );
  }

  Future<void> _onDeleteCoordinador(
    DeleteCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await deleteCoordinador(event.coordinadorId);

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Coordinador eliminado exitosamente.', isLoading: false));
        add(const FetchAllCoordinadoresEvent());
      },
    );
  }

  Future<void> _onUpdateCoordinador(
    UpdateCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await updateCoordinador(
      id: event.id,
      nombres: event.nombres,
      apellidos: event.apellidos,
      telefono: event.telefono,
    );

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Coordinador actualizado exitosamente.', isLoading: false));
        add(const FetchAllCoordinadoresEvent());
        add(const FetchRecintosEvent()); // In case it affects list of recintos too
      },
    );
  }

  Future<void> _onDesasignarCoordinador(
    DesasignarCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    final result = await desasignarCoordinador(event.recintoId);

    await result.fold(
      (error) async {
        emit(state.copyWith(errorMessage: error, isLoading: false));
      },
      (_) async {
        emit(state.copyWith(successMessage: 'Coordinador desasignado exitosamente.', isLoading: false));
        add(const FetchRecintosEvent());
      },
    );
  }
}
