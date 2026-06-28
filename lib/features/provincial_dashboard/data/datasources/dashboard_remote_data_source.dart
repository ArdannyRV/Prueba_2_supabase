import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/resultado_voto_entity.dart';
import '../models/candidato_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<ResultadoVotoEntity>> getResultadosPorCargo(String cargo);
}

@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final SupabaseClient supabaseClient;

  DashboardRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ResultadoVotoEntity>> getResultadosPorCargo(String cargo) async {
    try {
      final response = await supabaseClient
          .from('candidatos')
          .select('*, votos_candidatos(*)')
          .eq('dignidad', cargo);

      final List<ResultadoVotoEntity> resultados = [];

      for (var row in (response as List)) {
        final candidato = CandidatoModel.fromJson(row as Map<String, dynamic>);
        
        final List votosCandidatosData = row['votos_candidatos'] as List? ?? [];
        int totalVotos = 0;
        
        for (var votoData in votosCandidatosData) {
          totalVotos += (votoData['cantidad'] as int? ?? 0);
        }

        resultados.add(ResultadoVotoEntity(
          candidato: candidato,
          totalVotos: totalVotos,
        ));
      }

      // Ordenar por votos descendente
      resultados.sort((a, b) => b.totalVotos.compareTo(a.totalVotos));

      return resultados;
    } catch (e) {
      throw Exception('Error al obtener resultados: $e');
    }
  }
}
