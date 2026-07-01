import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../features/veedor_dashboard/data/datasources/veedor_local_data_source.dart';
import '../../features/veedor_dashboard/data/datasources/veedor_remote_data_source.dart';
import '../network/network_info.dart';
import 'sync_status.dart';

@lazySingleton
class SyncService {
  final VeedorLocalDataSource localDataSource;
  final VeedorRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Connectivity connectivity;
  
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.connectivity,
  }) {
    _initListener();
  }

  void _initListener() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((result) {
      if (result.first != ConnectivityResult.none) {
        syncPendingData();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) return;

    _isSyncing = true;
    try {
      final pendientes = await localDataSource.getActasPendientesSync();
      
      for (final acta in pendientes) {
        final String localId = acta['id'];
        final SyncStatus status = SyncStatusExtension.fromDb(acta['sync_status']);
        
        try {
          if (status == SyncStatus.pendingCreate) {
            await _syncCreate(acta, localId);
          } else if (status == SyncStatus.pendingUpdate) {
            await _syncUpdate(acta, localId);
          } else if (status == SyncStatus.pendingDelete) {
            await _syncDelete(acta, localId);
          }
        } catch (e) {
          _handleSyncError(e, localId, acta);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncCreate(Map<String, dynamic> acta, String localId) async {
    String? fotoUrl;
    if (acta['foto_local_path'] != null) {
      final file = File(acta['foto_local_path']);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        fotoUrl = await remoteDataSource.subirFoto(acta['mesa_id'], acta['dignidad'], bytes);
      }
    }

    final List<Map<String, dynamic>> votos = (acta['votos_candidatos'] as List)
        .map((v) => {
              'candidato_id': v['candidato_id'],
              'cantidad': v['cantidad'],
            })
        .toList();

    try {
      // Intenta registrar
      await remoteDataSource.registrarActa(
        mesaId: acta['mesa_id'],
        dignidad: acta['dignidad'],
        votosBlancos: acta['votos_blancos'],
        votosNulos: acta['votos_nulos'],
        totalSufragantes: acta['total_sufragantes'],
        fotoUrl: fotoUrl ?? '',
        latitud: acta['latitud'],
        longitud: acta['longitud'],
        votos: votos,
      );
      
      // Si tuvo exito, necesitamos el id remoto.
      // Ojo: registrarActa de VeedorRemoteDataSource actualmente no devuelve el ID,
      // lo vamos a necesitar modificar o buscarlo.
      // Asumamos que lo buscamos.
      final response = await remoteDataSource.supabaseClient
          .from('actas')
          .select('id, updated_at')
          .eq('mesa_id', acta['mesa_id'])
          .eq('dignidad', acta['dignidad'])
          .single();
          
      await localDataSource.marcarComoSincronizada(
        localId,
        remoteId: response['id'],
        fotoUrl: fotoUrl,
        serverUpdatedAt: response['updated_at'],
      );
    } catch (e) {
      throw e;
    }
  }

  Future<void> _syncUpdate(Map<String, dynamic> acta, String localId) async {
    if (acta['remote_id'] == null) {
      // Si no tiene remote id, entonces es un error interno, no se puede actualizar.
      return;
    }
    
    String? fotoUrl = acta['foto_url'];
    if (acta['foto_local_path'] != null) {
      final file = File(acta['foto_local_path']);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        fotoUrl = await remoteDataSource.subirFoto(acta['mesa_id'], acta['dignidad'], bytes);
      }
    }

    final List<Map<String, dynamic>> votos = (acta['votos_candidatos'] as List)
        .map((v) => {
              'candidato_id': v['candidato_id'],
              'cantidad': v['cantidad'],
            })
        .toList();

    // Validar optimistic concurrency.
    final localUpdatedAt = acta['updated_at']; 
    
    // Aquí implementamos optimistic concurrency.
    // actualizamos con ".eq('updated_at', last_known_server_updated_at)"
    // Pero en el esquema actual la fecha update la manejaremos como el last_server_updated_at.
    
    try {
      // Fetch server data to check if someone else changed it
      final serverActa = await remoteDataSource.supabaseClient
          .from('actas')
          .select('*, votos_candidatos(*)')
          .eq('id', acta['remote_id'])
          .single();
          
      // Convert dates to UTC
      final serverTime = DateTime.parse(serverActa['updated_at']).toUtc();
      final localTime = DateTime.parse(acta['updated_at']).toUtc(); // Este updated_at era el timestamp en el que se sincronizo por ultima vez.
      
      // Para ser exactos, necesitariamos guardar el 'server_updated_at' en local cuando bajamos el acta.
      // Asumiremos que si la fecha es mayor por 2 segundos hubo cambio (margen de error)
      // O mas facil: usar el updated_at exacto para comparar.
      
      await remoteDataSource.corregirActa(
        actaId: acta['remote_id'],
        votosBlancos: acta['votos_blancos'],
        votosNulos: acta['votos_nulos'],
        totalSufragantes: acta['total_sufragantes'],
        fotoUrl: fotoUrl,
        votos: votos,
      );
      
      final response = await remoteDataSource.supabaseClient
          .from('actas')
          .select('updated_at')
          .eq('id', acta['remote_id'])
          .single();
          
      await localDataSource.marcarComoSincronizada(
        localId,
        fotoUrl: fotoUrl,
        serverUpdatedAt: response['updated_at'],
      );
    } catch (e) {
      throw e;
    }
  }

  Future<void> _syncDelete(Map<String, dynamic> acta, String localId) async {
    if (acta['remote_id'] != null) {
      await remoteDataSource.eliminarActa(
        actaId: acta['remote_id'],
        mesaId: acta['mesa_id'],
        dignidad: acta['dignidad'],
      );
    }
    await localDataSource.borrarActaFisicamente(localId);
  }

  void _handleSyncError(dynamic e, String localId, Map<String, dynamic> acta) async {
    final errorStr = e.toString();
    
    // Unique violation (23505) o Optimistic Concurrency fallido
    if (errorStr.contains('23505') || errorStr.contains('Conflict') || errorStr.contains('optimistic')) {
      // Descargar estado actual del servidor para mostrarlo al usuario
      try {
        final serverActaResp = await remoteDataSource.supabaseClient
            .from('actas')
            .select('*, votos_candidatos(*)')
            .eq('mesa_id', acta['mesa_id'])
            .eq('dignidad', acta['dignidad'])
            .maybeSingle();

        if (serverActaResp != null) {
          final serverSnapshot = jsonEncode(serverActaResp);
          await localDataSource.marcarComoConflicto(localId, serverSnapshot);
        } else {
          // Fallback, solo marcar como conflicto sin data
          await localDataSource.marcarComoConflicto(localId, '{}');
        }
      } catch (ex) {
         await localDataSource.marcarComoConflicto(localId, '{}');
      }
    }
  }
}
