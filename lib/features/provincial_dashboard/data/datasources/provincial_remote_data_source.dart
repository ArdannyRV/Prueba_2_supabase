import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/app_constants.dart';
import '../models/recinto_model.dart';
import '../models/coordinador_model.dart';

abstract class ProvincialRemoteDataSource {
  Future<List<RecintoModel>> getRecintos();
  Future<List<CoordinadorModel>> getUnassignedCoordinadores();
  Future<List<CoordinadorModel>> getAllCoordinadores();
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
  Future<void> createCoordinadorIndependiente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  });
  Future<void> updateCoordinador({
    required String id,
    required String nombres,
    required String apellidos,
    required String telefono,
  });
  Future<void> deleteCoordinador(String coordinadorId);
  Future<void> asignarCoordinador(String recintoId, String coordinadorId);
  Future<void> deleteRecinto(String recintoId);
  Future<void> desasignarCoordinador(String recintoId);
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
          .select('*, mesas(*, actas(id, latitud, longitud)), coordinador:perfiles!coordinador_id(nombres, apellidos)')
          .order('nombre');

      return (response as List)
          .map((json) => RecintoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener recintos: $e');
    }
  }

  @override
  Future<List<CoordinadorModel>> getUnassignedCoordinadores() async {
    try {
      // 1. Obtener los IDs de coordinadores que ya están asignados a un recinto
      final recintosRes = await supabaseClient
          .from('recintos')
          .select('coordinador_id')
          .not('coordinador_id', 'is', null);
      
      final assignedIds = (recintosRes as List)
          .map((r) => r['coordinador_id'] as String)
          .toList();

      // 2. Obtener perfiles que son coordinadores y NO están en la lista de asignados
      var query = supabaseClient
          .from('perfiles')
          .select()
          .eq('rol', 'coordinador_recinto');

      if (assignedIds.isNotEmpty) {
        final formattedIds = '(${assignedIds.join(',')})';
        query = query.filter('id', 'not.in', formattedIds);
      }

      final response = await query;
      return (response as List)
          .map((json) => CoordinadorModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener coordinadores vacantes: $e');
    }
  }

  @override
  Future<List<CoordinadorModel>> getAllCoordinadores() async {
    try {
      final response = await supabaseClient
          .from('perfiles')
          .select('*, recintos!coordinador_id(nombre)')
          .eq('rol', 'coordinador_recinto')
          .order('nombres');

      return (response as List).map((json) {
        // Extraer nombre del recinto del join
        final recintoData = json['recintos'];
        final recintoNombre = recintoData != null
            ? (recintoData is List
                ? (recintoData.isNotEmpty ? recintoData[0]['nombre'] : null)
                : recintoData['nombre'])
            : null;
        return CoordinadorModel.fromJson({...json, 'recinto_nombre': recintoNombre});
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener coordinadores: $e');
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
      // Validar que el recinto no tenga coordinador
      final recinto = await supabaseClient
          .from('recintos')
          .select('coordinador_id')
          .eq('id', recintoId)
          .single();

      if (recinto['coordinador_id'] != null) {
        throw Exception('Este recinto ya tiene un coordinador asignado.');
      }

      // ✅ Llamar a la Edge Function en vez de crear secClient
      final response = await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'email': correo,
          'password': 'Ecuador2026',
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'rol': 'coordinador_recinto',
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw Exception('Error al crear usuario: $error');
      }

      final userId = response.data['userId'];

      // Asignar coordinador al recinto
      await supabaseClient
          .from('recintos')
          .update({'coordinador_id': userId})
          .eq('id', recintoId);

    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate') || msg.contains('unique') || msg.contains('cedula')) {
        throw Exception('Esta cédula ya está registrada.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> createCoordinadorIndependiente({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
  }) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'email': correo,
          'password': 'Ecuador2026',
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'rol': 'coordinador_recinto',
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw Exception('Error al crear usuario: $error');
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('duplicate') || msg.contains('unique') || msg.contains('cedula')) {
        throw Exception('Esta cédula ya está registrada.');
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateCoordinador({
    required String id,
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    try {
      await supabaseClient.from('perfiles').update({
        'nombres': nombres,
        'apellidos': apellidos,
        'telefono': telefono,
      }).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar coordinador: $e');
    }
  }

  @override
  Future<void> deleteCoordinador(String coordinadorId) async {
    try {
      // Nota: Eliminar un usuario completamente requiere Supabase Admin API.
      // Si no tenemos admin API, eliminaremos solo el perfil o le cambiaremos el rol.
      // El requerimiento decía "Eliminar en Supabase", así que borramos de 'perfiles' por ahora.
      // (O puede fallar si hay llave foránea. Lo ideal es desactivarlo).
      await supabaseClient.from('perfiles').delete().eq('id', coordinadorId);
    } catch (e) {
      throw Exception('Error al eliminar coordinador: $e');
    }
  }

  @override
  Future<void> asignarCoordinador(String recintoId, String coordinadorId) async {
    try {
      await supabaseClient
          .from('recintos')
          .update({'coordinador_id': coordinadorId})
          .eq('id', recintoId);
    } catch (e) {
      throw Exception('Error al asignar coordinador: $e');
    }
  }

  @override
  Future<void> deleteRecinto(String recintoId) async {
    try {
      await supabaseClient.from('recintos').delete().eq('id', recintoId);
    } catch (e) {
      throw Exception('Error al eliminar recinto: $e');
    }
  }

  @override
  Future<void> desasignarCoordinador(String recintoId) async {
    try {
      await supabaseClient
          .from('recintos')
          .update({'coordinador_id': null})
          .eq('id', recintoId);
    } catch (e) {
      throw Exception('Error al desasignar coordinador: $e');
    }
  }
}
