import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/app_constants.dart';
import '../models/recinto_model.dart';

abstract class ProvincialRemoteDataSource {
  Future<List<RecintoModel>> getRecintos();
  Future<void> createRecinto({
    required String nombre,
    required String parroquia,
    required String canton,
    required int totalMesas,
  });
  Future<void> createCoordinadorRecinto({
    required String recintoId,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  });
}

@LazySingleton(as: ProvincialRemoteDataSource)
class ProvincialRemoteDataSourceImpl implements ProvincialRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProvincialRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<RecintoModel>> getRecintos() async {
    try {
      final response = await supabaseClient
          .from('recintos')
          .select('*, mesas(*, actas(id, latitud, longitud))')
          .order('nombre');

      return (response as List)
          .map((json) => RecintoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener recintos: $e');
    }
  }

  @override
  Future<void> createRecinto({
    required String nombre,
    required String parroquia,
    required String canton,
    required int totalMesas,
  }) async {
    try {
      // 1. Insertar recinto
      final recintoResponse = await supabaseClient
          .from('recintos')
          .insert({
            'nombre': nombre,
            'parroquia': parroquia,
            'canton': canton,
            'provincia': 'Pichincha', // Asumido o configurable
          })
          .select()
          .single();

      final recintoId = recintoResponse['id'];

      // 2. Insertar mesas
      final mesasToInsert = List.generate(
        totalMesas,
        (index) => {
          'numero_mesa': index + 1,
          'recinto_id': recintoId,
        },
      );

      await supabaseClient.from('mesas').insert(mesasToInsert);
    } catch (e) {
      throw Exception('Error al crear recinto: $e');
    }
  }

  @override
  Future<void> createCoordinadorRecinto({
    required String recintoId,
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  }) async {
    try {
      // 1. Validar que el recinto no tenga coordinador
      final recinto = await supabaseClient
          .from('recintos')
          .select('coordinador_id')
          .eq('id', recintoId)
          .single();

      if (recinto['coordinador_id'] != null) {
        throw Exception('Este recinto ya tiene un coordinador asignado.');
      }

      // 2. Llamar a la Edge Function para crear usuario y perfil
      final response = await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo': correo,
          'rol': 'coordinador_recinto',
        },
      );

      if (response.status != 200) {
        final errorMsg = response.data['error'] ?? '';
        if (errorMsg.toString().contains('already been registered')) {
          throw Exception('El correo electrónico ya está registrado en el sistema.');
        }
        throw Exception('Error al crear usuario: $errorMsg');
      }

      final userId = response.data['userId'] as String;

      // 3. Asignar coordinador al recinto
      await supabaseClient
          .from('recintos')
          .update({'coordinador_id': userId})
          .eq('id', recintoId);
    } catch (e) {
      throw Exception('Error al crear coordinador: $e');
    }
  }
}
