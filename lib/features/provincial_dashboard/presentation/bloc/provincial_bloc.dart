import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/create_coordinador_usecase.dart';
import '../../domain/usecases/create_recinto_usecase.dart';
import '../../domain/usecases/get_recintos_usecase.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

@injectable
class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintosUseCase getRecintos;
  final CreateRecintoUseCase createRecinto;
  final CreateCoordinadorUseCase createCoordinador;

  ProvincialBloc({
    required this.getRecintos,
    required this.createRecinto,
    required this.createCoordinador,
  }) : super(ProvincialInitial()) {
    on<FetchRecintosEvent>(_onFetchRecintos);
    on<CreateRecintoEvent>(_onCreateRecinto);
    on<CreateCoordinadorEvent>(_onCreateCoordinador);
  }

  Future<void> _onFetchRecintos(
    FetchRecintosEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(ProvincialLoading());
    final result = await getRecintos();
    result.fold(
      (error) => emit(ProvincialError(error)),
      (recintos) => emit(ProvincialLoaded(recintos)),
    );
  }

  Future<void> _onCreateRecinto(
    CreateRecintoEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    // Keep previous state if we want to retain the list, but typically we show a loading overlay
    // For simplicity, we just emit loading, then fetch again
    emit(ProvincialLoading());
    final result = await createRecinto(
      nombre: event.nombre,
      parroquia: event.parroquia,
      canton: event.canton,
      totalMesas: event.totalMesas,
    );

    await result.fold(
      (error) async {
        emit(ProvincialActionError(error));
        // Re-fetch to restore list
        add(const FetchRecintosEvent());
      },
      (_) async {
        emit(const ProvincialActionSuccess('Recinto creado exitosamente.'));
        add(const FetchRecintosEvent());
      },
    );
  }

  Future<void> _onCreateCoordinador(
    CreateCoordinadorEvent event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(ProvincialLoading());
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
        emit(ProvincialActionError(error));
        add(const FetchRecintosEvent());
      },
      (_) async {
        emit(const ProvincialActionSuccess('Coordinador asignado exitosamente.'));
        add(const FetchRecintosEvent());
      },
    );
  }
}
