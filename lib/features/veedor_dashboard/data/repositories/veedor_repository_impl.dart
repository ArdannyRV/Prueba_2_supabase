import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/sync_status.dart';
import '../../domain/entities/mesa_veedor_entity.dart';
import '../../domain/repositories/veedor_repository.dart';
import '../datasources/veedor_local_data_source.dart';
import '../datasources/veedor_remote_data_source.dart';

@LazySingleton(as: VeedorRepository)
class VeedorRepositoryImpl implements VeedorRepository {
  final VeedorLocalDataSource localDataSource;
  final VeedorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SyncService syncService;

  VeedorRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.syncService,
  });

  @override
  Future<List<MesaVeedorEntity>> getMisAsignadas() async {
    final userId = remoteDataSource.supabaseClient.auth.currentUser!.id;
    
    if (await networkInfo.isConnected) {
      try {
        final mesasRemotas = await remoteDataSource.getMisAsignadas();
        await localDataSource.cacheMesasAsignadas(userId, mesasRemotas);
        return mesasRemotas;
      } catch (e) {
        // Si falla la red temporalmente o hay timeout, fallback a local
        return await localDataSource.getMesasAsignadasCached(userId);
      }
    } else {
      return await localDataSource.getMesasAsignadasCached(userId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMisActas(String mesaId) async {
    // Si estamos conectados, obtenemos remotas, las cacheamos / combinamos con las pendientes locales
    if (await networkInfo.isConnected) {
      try {
        final actasRemotas = await remoteDataSource.getMisActas(mesaId);
        
        // Sobreescribir el local con la info del server, solo para las que NO están pendientes ni en conflicto.
        for (final actaR in actasRemotas) {
          final localActa = await localDataSource.getActaLocalByRemoteId(actaR['id']);
          
          if (localActa == null) {
            // Guardar en local como synced
            await localDataSource.guardarActaLocal(
              localId: const Uuid().v4(),
              mesaId: mesaId,
              dignidad: actaR['dignidad'],
              votosBlancos: actaR['votos_blancos'],
              votosNulos: actaR['votos_nulos'],
              totalSufragantes: actaR['total_sufragantes'],
              latitud: actaR['latitud'] ?? 0.0,
              longitud: actaR['longitud'] ?? 0.0,
              fotoLocalPath: null,
              fotoUrl: actaR['foto_url'],
              corregida: actaR['corregida'] ?? false,
              remoteId: actaR['id'],
              votos: (actaR['votos_candidatos'] as List).map((v) => {
                'candidato_id': v['candidatos'] != null ? v['candidatos']['id'] : v['candidato_id'],
                'cantidad': v['cantidad'],
              }).toList(),
              status: SyncStatus.synced,
            );
          } else {
            // Si existe localmente pero está synced, actualizamos valores
            if (localActa['sync_status'] == SyncStatus.synced.toDb()) {
              await localDataSource.actualizarActaLocal(
                localId: localActa['id'],
                votosBlancos: actaR['votos_blancos'],
                votosNulos: actaR['votos_nulos'],
                totalSufragantes: actaR['total_sufragantes'],
                fotoUrl: actaR['foto_url'],
                votos: (actaR['votos_candidatos'] as List).map((v) => {
                  'candidato_id': v['candidatos'] != null ? v['candidatos']['id'] : v['candidato_id'],
                  'cantidad': v['cantidad'],
                }).toList(),
                status: SyncStatus.synced,
              );
            }
          }
        }
      } catch (e) {
        // ignore and fallback
      }
    }
    
    // Al final, la verdad es la BD local (que contiene los pendientes y conflictos)
    return await localDataSource.getMisActasLocal(mesaId);
  }

  @override
  Future<List<Map<String, dynamic>>> getCandidatos(String dignidad) async {
    if (await networkInfo.isConnected) {
      try {
        final candidatosRemotos = await remoteDataSource.getCandidatos(dignidad);
        await localDataSource.cacheCandidatos(dignidad, candidatosRemotos);
        return candidatosRemotos;
      } catch (e) {
        final locales = await localDataSource.getCandidatosCached(dignidad);
        if (locales.isEmpty) throw Exception('Necesitas conectarte al menos una vez antes de poder votar.');
        return locales;
      }
    } else {
      final locales = await localDataSource.getCandidatosCached(dignidad);
      if (locales.isEmpty) throw Exception('Necesitas conectarte al menos una vez antes de poder votar.');
      return locales;
    }
  }

  @override
  Future<void> registrarActa({
    required String mesaId,
    required String dignidad,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    required String fotoLocalPath,
    required double latitud,
    required double longitud,
    required List<Map<String, dynamic>> votos,
  }) async {
    final localId = const Uuid().v4();
    
    await localDataSource.guardarActaLocal(
      localId: localId,
      mesaId: mesaId,
      dignidad: dignidad,
      votosBlancos: votosBlancos,
      votosNulos: votosNulos,
      totalSufragantes: totalSufragantes,
      latitud: latitud,
      longitud: longitud,
      fotoLocalPath: fotoLocalPath,
      fotoUrl: null,
      votos: votos,
      status: SyncStatus.pendingCreate,
    );

    // Intentar sincronizar inmediatamente y esperar el resultado si hay red
    await syncService.syncPendingData();
  }

  @override
  Future<void> corregirActa({
    required Map<String, dynamic> actaOriginal,
    required String actaLocalId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoLocalPath,
    required List<Map<String, dynamic>> votos,
  }) async {
    assert(actaLocalId.isNotEmpty, 'El id del acta no puede ser vacío o nulo');

    // 1. Verificar si existe localmente
    final actaLocal = await localDataSource.getActaLocalById(actaLocalId);
    
    // 2. Si no existe, crearla (upsert) con los datos originales en memoria
    if (actaLocal == null) {
      final List<Map<String, dynamic>> votosOriginalesFlat = (actaOriginal['votos_candidatos'] as List).map((v) {
        return {
          'candidato_id': v['candidatos'] != null ? v['candidatos']['id'] : v['candidato_id'],
          'cantidad': v['cantidad'],
        };
      }).toList();

      await localDataSource.guardarActaLocal(
        localId: actaLocalId, // usar el mismo UUID (remoto o local)
        mesaId: actaOriginal['mesa_id'],
        dignidad: actaOriginal['dignidad'],
        votosBlancos: actaOriginal['votos_blancos'],
        votosNulos: actaOriginal['votos_nulos'],
        totalSufragantes: actaOriginal['total_sufragantes'],
        latitud: actaOriginal['latitud'] ?? 0.0,
        longitud: actaOriginal['longitud'] ?? 0.0,
        fotoLocalPath: null,
        fotoUrl: actaOriginal['foto_url'],
        votos: votosOriginalesFlat,
        status: SyncStatus.synced, // Estado base = sincronizado
        remoteId: actaLocalId, // Porque viene del servidor
        corregida: actaOriginal['corregida'] == 1 || actaOriginal['corregida'] == true,
      );
    }

    // 3. Aplicar la corrección
    await localDataSource.actualizarActaLocal(
      localId: actaLocalId,
      votosBlancos: votosBlancos,
      votosNulos: votosNulos,
      totalSufragantes: totalSufragantes,
      fotoLocalPath: fotoLocalPath,
      votos: votos,
      status: SyncStatus.pendingUpdate,
    );
    await syncService.syncPendingData();
  }

  @override
  Future<void> eliminarActa({
    required String actaLocalId,
    required String mesaId,
    required String dignidad,
  }) async {
    await localDataSource.eliminarActaLocal(actaLocalId, SyncStatus.pendingDelete);
    await syncService.syncPendingData();
  }

  @override
  Future<List<Map<String, dynamic>>> getActasEnConflicto() async {
    return await localDataSource.getActasEnConflicto();
  }

  @override
  Future<void> resolverConflicto({
    required String actaLocalId,
    required bool mantenerLocal,
  }) async {
    if (mantenerLocal) {
      // Re-intentar como una actualización (el snapshot del server se ignora localmente)
      // Cambiamos el estado a pendingUpdate
      final db = await localDataSource.appDatabase.database;
      await db.update('actas_local', {
        'sync_status': SyncStatus.pendingUpdate.toDb(),
        'server_snapshot': null,
      }, where: 'id = ?', whereArgs: [actaLocalId]);
      
      syncService.syncPendingData();
    } else {
      // Usar lo del server.
      // Reemplazamos toda la data local por el server_snapshot
      final db = await localDataSource.appDatabase.database;
      final query = await db.query('actas_local', where: 'id = ?', whereArgs: [actaLocalId]);
      if (query.isNotEmpty) {
        final serverSnapshotStr = query.first['server_snapshot'] as String?;
        if (serverSnapshotStr != null && serverSnapshotStr.isNotEmpty) {
          final serverData = jsonDecode(serverSnapshotStr) as Map<String, dynamic>;
          
          await localDataSource.actualizarActaLocal(
            localId: actaLocalId,
            votosBlancos: serverData['votos_blancos'],
            votosNulos: serverData['votos_nulos'],
            totalSufragantes: serverData['total_sufragantes'],
            fotoUrl: serverData['foto_url'],
            votos: (serverData['votos_candidatos'] as List).cast<Map<String, dynamic>>(),
            status: SyncStatus.synced,
          );
        }
      }
    }
  }
}
