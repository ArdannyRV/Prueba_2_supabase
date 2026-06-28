import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_resultados_por_cargo_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetResultadosPorCargoUseCase getResultadosPorCargo;

  DashboardBloc(this.getResultadosPorCargo) : super(DashboardInitial()) {
    on<FetchResultadosEvent>(_onFetchResultados);
  }

  Future<void> _onFetchResultados(
    FetchResultadosEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final alcaldeResult = await getResultadosPorCargo('alcaldia');
    final prefectoResult = await getResultadosPorCargo('prefectura');

    alcaldeResult.fold(
      (error) => emit(DashboardError(error)),
      (resultadosAlcalde) {
        prefectoResult.fold(
          (error) => emit(DashboardError(error)),
          (resultadosPrefecto) {
            emit(DashboardLoaded(
              resultadosAlcalde: resultadosAlcalde,
              resultadosPrefecto: resultadosPrefecto,
            ));
          },
        );
      },
    );
  }
}
