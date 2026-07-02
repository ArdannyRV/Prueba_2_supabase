import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/email_service.dart';
import '../../domain/entities/mesa_detalle_entity.dart';
import '../../domain/entities/veedor_entity.dart';

class RecintoCoordRemoteDataSource {
  final SupabaseClient supabaseClient;

  RecintoCoordRemoteDataSource(this.supabaseClient);

  Future<String> getRecintoId() async {
    final userId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient
        .from('recintos')
        .select('id')
        .eq('coordinador_id', userId)
        .maybeSingle();
        
    if (response == null) {
      throw Exception('No tienes un recinto asignado');
    }
    return response['id'] as String;
  }

  Future<String> getRecintoNombre() async {
    final userId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient
        .from('recintos')
        .select('nombre')
        .eq('coordinador_id', userId)
        .maybeSingle();
        
    if (response == null) {
      throw Exception('No tienes un recinto asignado');
    }
    return response['nombre'] as String;
  }

  Future<List<MesaDetalleEntity>> getMesas(String recintoId) async {
    final response = await supabaseClient
        .from('mesas')
        .select('*, perfiles!veedor_id(nombres, apellidos), actas(*, votos_candidatos(candidato_id, cantidad, candidatos(id, nombre_candidato, organizacion_politica, dignidad)))')
        .eq('recinto_id', recintoId)
        .order('numero_mesa');

    return (response as List).map((row) {
      final String id = row['id'];
      final int numeroMesa = row['numero_mesa'];
      final String? veedorId = row['veedor_id'];
      
      String? veedorNombre;
      if (row['perfiles'] != null) {
        final p = row['perfiles'];
        veedorNombre = '${p['nombres'] ?? ''} ${p['apellidos'] ?? ''}'.trim();
      }

      final List actas = row['actas'] ?? [];
      final bool tieneActa = actas.isNotEmpty;
      
      String? actaIdAlcaldia;
      String? actaIdPrefectura;
      int? votosBlaancosAlcaldia, votosNulosAlcaldia, totalSufragantesAlcaldia;
      int? votosBlaancosPrefectura, votosNulosPrefectura, totalSufragantesPrefectura;
      String? fotoUrlAlcaldia, fotoUrlPrefectura;
      double? latitudAlcaldia, longitudAlcaldia;
      double? latitudPrefectura, longitudPrefectura;
      bool? corregida;
      
      List<Map<String, dynamic>> votosAlcaldia = [];
      List<Map<String, dynamic>> votosPrefectura = [];

      if (tieneActa) {
        corregida = actas.any((a) => a['corregida'] == true);

        for (final acta in actas) {
          final dignidad = acta['dignidad'] as String?;
          final foto = acta['foto_url'] as String?;
          final lat = (acta['latitud'] as num?)?.toDouble();
          final lng = (acta['longitud'] as num?)?.toDouble();
          final blancos = acta['votos_blancos'] as int?;
          final nulos = acta['votos_nulos'] as int?;
          final total = acta['total_sufragantes'] as int?;

          if (dignidad == 'alcaldia') {
            actaIdAlcaldia = acta['id'];
            fotoUrlAlcaldia = foto;
            latitudAlcaldia = lat;
            longitudAlcaldia = lng;
            votosBlaancosAlcaldia = blancos;
            votosNulosAlcaldia = nulos;
            totalSufragantesAlcaldia = total;
          } else if (dignidad == 'prefectura') {
            actaIdPrefectura = acta['id'];
            fotoUrlPrefectura = foto;
            latitudPrefectura = lat;
            longitudPrefectura = lng;
            votosBlaancosPrefectura = blancos;
            votosNulosPrefectura = nulos;
            totalSufragantesPrefectura = total;
          }

          final List votos = acta['votos_candidatos'] ?? [];
          for (final voto in votos) {
            final cand = voto['candidatos'];
            if (cand == null) continue;
            final mapVoto = {
              'candidato_id': cand['id'] ?? voto['candidato_id'],
              'nombre_candidato': cand['nombre_candidato'],
              'organizacion_politica': cand['organizacion_politica'],
              'cantidad': voto['cantidad'],
            };
            if (cand['dignidad'] == 'alcaldia') {
              votosAlcaldia.add(mapVoto);
            } else if (cand['dignidad'] == 'prefectura') {
              votosPrefectura.add(mapVoto);
            }
          }
        }
      }

      return MesaDetalleEntity(
        id: id,
        numeroMesa: row['numero_mesa'],
        veedorId: row['veedor_id'],
        veedorNombre: veedorNombre,
        tieneActa: tieneActa,
        corregida: corregida,
        actaIdAlcaldia: actaIdAlcaldia,
        actaIdPrefectura: actaIdPrefectura,
        votosBlaancosAlcaldia: votosBlaancosAlcaldia,
        votosNulosAlcaldia: votosNulosAlcaldia,
        totalSufragantesAlcaldia: totalSufragantesAlcaldia,
        votosBlaancosPrefectura: votosBlaancosPrefectura,
        votosNulosPrefectura: votosNulosPrefectura,
        totalSufragantesPrefectura: totalSufragantesPrefectura,
        fotoUrlAlcaldia: fotoUrlAlcaldia,
        fotoUrlPrefectura: fotoUrlPrefectura,
        latitudAlcaldia: latitudAlcaldia,
        longitudAlcaldia: longitudAlcaldia,
        latitudPrefectura: latitudPrefectura,
        longitudPrefectura: longitudPrefectura,
        votosAlcaldia: votosAlcaldia,
        votosPrefectura: votosPrefectura,
      );
    }).toList();
  }

  Future<List<VeedorEntity>> getVeedoresDelRecinto(String recintoId) async {
    final response = await supabaseClient
        .from('mesas')
        .select('veedor_id, numero_mesa, perfiles!veedor_id(*)')
        .eq('recinto_id', recintoId)
        .not('veedor_id', 'is', null);

    return (response as List).map((row) {
      final p = row['perfiles'];
      return VeedorEntity(
        id: p['id'],
        cedula: p['cedula'],
        nombres: p['nombres'],
        apellidos: p['apellidos'],
        telefono: p['telefono'],
        correo: p['correo'],
        mesaAsignada: 'Mesa N°${row['numero_mesa']}',
      );
    }).toList();
  }

  Future<List<VeedorEntity>> getTodosVeedores(String recintoId) async {
    final userId = supabaseClient.auth.currentUser!.id;
    final veedoresResp = await supabaseClient
        .from('perfiles')
        .select()
        .eq('rol', 'veedor')
        .eq('coordinador_id', userId);

    final mesasResp = await supabaseClient
        .from('mesas')
        .select('veedor_id, numero_mesa')
        .eq('recinto_id', recintoId)
        .not('veedor_id', 'is', null);

    final mapMesas = {
      for (final m in mesasResp) m['veedor_id'] as String: m['numero_mesa'] as int
    };

    return (veedoresResp as List).map((p) {
      final numMesa = mapMesas[p['id']];
      return VeedorEntity(
        id: p['id'],
        cedula: p['cedula'],
        nombres: p['nombres'],
        apellidos: p['apellidos'],
        telefono: p['telefono'],
        correo: p['correo'],
        mesaAsignada: numMesa != null ? 'Mesa N°$numMesa' : null,
      );
    }).toList();
  }

  Future<void> asignarVeedor(String mesaId, String veedorId) async {
    await supabaseClient
        .from('mesas')
        .update({'veedor_id': veedorId})
        .eq('id', mesaId);
  }

  Future<void> desasignarVeedor(String mesaId) async {
    await supabaseClient
        .from('mesas')
        .update({'veedor_id': null})
        .eq('id', mesaId);
  }

  Future<void> crearVeedor({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correo,
    required String recintoId,
    required String coordinadorId,
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
          'rol': 'veedor',
          'recinto_id': recintoId,
          'coordinador_id': coordinadorId,
        },
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw Exception('Error al crear usuario: $error');
      }

      await EmailService.sendEmail(
        to: correo,
        subject: 'Bienvenido al sistema',
        text: 'Tu cuenta ha sido creada.\nUsuario: $correo\nContraseña temporal: Ecuador2026',
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Esta cédula ya está registrada') || msg.contains('cedula') || msg.contains('duplicate') || msg.contains('unique')) {
        throw Exception('Esta cédula ya está en uso');
      }
      throw Exception(msg);
    }
  }

  Future<void> eliminarVeedor(String veedorId) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'delete-user',
        body: {'userId': veedorId},
      );

      if (response.status != 200) {
        final error = response.data['error'] ?? 'Error desconocido';
        throw Exception('Error al eliminar usuario: $error');
      }
    } catch (e) {
      throw Exception('Error al eliminar veedor: $e');
    }
  }

  Future<void> corregirActa({
    required String actaId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoUrl,
    required List<Map<String, dynamic>> votos,
  }) async {
    // 1. Update acta
    final actasData = {
      'votos_blancos': votosBlancos,
      'votos_nulos': votosNulos,
      'total_sufragantes': totalSufragantes,
      'corregida': true,
    };
    if (fotoUrl != null) actasData['foto_url'] = fotoUrl;

    await supabaseClient
        .from('actas')
        .update(actasData)
        .eq('id', actaId);

    // 2. Update votos_candidatos
    for (final voto in votos) {
      await supabaseClient
          .from('votos_candidatos')
          .update({'cantidad': voto['cantidad']})
          .eq('acta_id', actaId)
          .eq('candidato_id', voto['candidato_id']); // This assumes we have candidato_id, but the entity only has nombre.
          // Let's assume the UI sends the candidato_id in the map
    }
  }

  Future<void> actualizarVeedor({
    required String id,
    required String nombres,
    required String apellidos,
    required String telefono,
  }) async {
    await supabaseClient.from('perfiles').update({
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
    }).eq('id', id);
  }
  Future<String> subirFotoActa({
    required String mesaId,
    required String dignidad,
    required List<int> bytes,
  }) async {
    final path = 'actas/$mesaId/$dignidad/acta.jpg';
    await supabaseClient.storage.from('actas-fotos').uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );
    return supabaseClient.storage.from('actas-fotos').getPublicUrl(path);
  }

  Future<void> corregirActaPorDignidad({
    required String actaId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoUrl,
    required List<Map<String, dynamic>> votos,
  }) async {
    final actasData = <String, dynamic>{
      'votos_blancos': votosBlancos,
      'votos_nulos': votosNulos,
      'total_sufragantes': totalSufragantes,
      'corregida': true,
    };
    if (fotoUrl != null) actasData['foto_url'] = fotoUrl;

    await supabaseClient.from('actas').update(actasData).eq('id', actaId);

    for (final voto in votos) {
      await supabaseClient
          .from('votos_candidatos')
          .update({'cantidad': voto['cantidad']})
          .eq('acta_id', actaId)
          .eq('candidato_id', voto['candidato_id']);
    }
  }
}
