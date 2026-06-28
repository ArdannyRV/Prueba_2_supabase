import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/mesa_veedor_entity.dart';

class VeedorRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  VeedorRemoteDataSource(this.supabaseClient);

  // Mesas asignadas al veedor logueado con estado de actas
  Future<List<MesaVeedorEntity>> getMisAsignadas() async {
    final userId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient
        .from('mesas')
        .select('id, numero_mesa, recintos(nombre), actas(dignidad)')
        .eq('veedor_id', userId)
        .order('numero_mesa');

    return (response as List).map((row) {
      final List actas = row['actas'] ?? [];
      return MesaVeedorEntity(
        id: row['id'],
        numeroMesa: row['numero_mesa'],
        recintoNombre: row['recintos']?['nombre'] ?? '',
        tieneActaAlcaldia: actas.any((a) => a['dignidad'] == 'alcaldia'),
        tieneActaPrefectura: actas.any((a) => a['dignidad'] == 'prefectura'),
      );
    }).toList();
  }

  // Candidatos por dignidad para el formulario
  Future<List<Map<String, dynamic>>> getCandidatos(String dignidad) async {
    final response = await supabaseClient
        .from('candidatos')
        .select()
        .eq('dignidad', dignidad)
        .order('lista_numero');
    return List<Map<String, dynamic>>.from(response);
  }

  // Subir foto a Supabase Storage bucket 'actas-fotos'
  Future<String> subirFoto(String mesaId, String dignidad, List<int> bytes) async {
    final path = 'actas/$mesaId/$dignidad/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabaseClient.storage.from('actas-fotos').uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );
    return supabaseClient.storage.from('actas-fotos').getPublicUrl(path);
  }

  // Guardar acta nueva con sus votos
  Future<void> registrarActa({
    required String mesaId,
    required String dignidad,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    required String fotoUrl,
    required double latitud,
    required double longitud,
    required List<Map<String, dynamic>> votos, // [{candidato_id, cantidad}]
  }) async {
    final actaResp = await supabaseClient.from('actas').insert({
      'mesa_id': mesaId,
      'dignidad': dignidad,
      'votos_blancos': votosBlancos,
      'votos_nulos': votosNulos,
      'total_sufragantes': totalSufragantes,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
      'corregida': false,
    }).select('id').single();

    final actaId = actaResp['id'] as String;

    for (final voto in votos) {
      await supabaseClient.from('votos_candidatos').insert({
        'acta_id': actaId,
        'candidato_id': voto['candidato_id'],
        'cantidad': voto['cantidad'],
      });
    }
  }

  // Obtener actas ya registradas con sus votos (para mis_actas_page y corrección)
  Future<List<Map<String, dynamic>>> getMisActas(String mesaId) async {
    final response = await supabaseClient
        .from('actas')
        .select('*, votos_candidatos(cantidad, candidatos(id, nombre_candidato, organizacion_politica, dignidad))')
        .eq('mesa_id', mesaId);
    return List<Map<String, dynamic>>.from(response);
  }

  // Corregir acta existente
  Future<void> corregirActa({
    required String actaId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoUrl,
    required List<Map<String, dynamic>> votos, // [{candidato_id, cantidad}]
  }) async {
    final update = <String, dynamic>{
      'votos_blancos': votosBlancos,
      'votos_nulos': votosNulos,
      'total_sufragantes': totalSufragantes,
      'corregida': true,
    };
    if (fotoUrl != null) update['foto_url'] = fotoUrl;

    await supabaseClient.from('actas').update(update).eq('id', actaId);

    for (final voto in votos) {
      await supabaseClient.from('votos_candidatos')
          .update({'cantidad': voto['cantidad']})
          .eq('acta_id', actaId)
          .eq('candidato_id', voto['candidato_id']);
    }
  }
}
