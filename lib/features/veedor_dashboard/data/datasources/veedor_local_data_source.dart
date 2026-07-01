import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/database/app_database.dart';
import '../../../../../core/sync/sync_status.dart';
import '../../domain/entities/mesa_veedor_entity.dart';

@lazySingleton
class VeedorLocalDataSource {
  final AppDatabase appDatabase;

  VeedorLocalDataSource(this.appDatabase);

  // --- Cache de Mesas ---

  Future<void> cacheMesasAsignadas(String veedorId, List<MesaVeedorEntity> mesas) async {
    final db = await appDatabase.database;
    await db.transaction((txn) async {
      // Eliminar las mesas previas de este veedor
      final deleted = await txn.delete('mesas_local', where: 'veedor_id = ?', whereArgs: [veedorId]);
      
      int inserted = 0;
      for (final mesa in mesas) {
        await txn.insert('mesas_local', {
          'id': mesa.id,
          'veedor_id': veedorId,
          'numero_mesa': mesa.numeroMesa,
          'recinto_nombre': mesa.recintoNombre,
          'tiene_acta_alcaldia': mesa.tieneActaAlcaldia ? 1 : 0,
          'tiene_acta_prefectura': mesa.tieneActaPrefectura ? 1 : 0,
        });
        inserted++;
      }
      
      debugPrint('cacheMesasAsignadas: Eliminadas \$deleted mesas locales, Insertadas \$inserted nuevas mesas para veedor \$veedorId');
    });
  }

  Future<List<MesaVeedorEntity>> getMesasAsignadasCached(String veedorId) async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mesas_local',
      where: 'veedor_id = ?',
      whereArgs: [veedorId],
      orderBy: 'numero_mesa ASC',
    );

    return List.generate(maps.length, (i) {
      return MesaVeedorEntity(
        id: maps[i]['id'] as String,
        numeroMesa: maps[i]['numero_mesa'] as int,
        recintoNombre: maps[i]['recinto_nombre'] as String,
        tieneActaAlcaldia: (maps[i]['tiene_acta_alcaldia'] as int) == 1,
        tieneActaPrefectura: (maps[i]['tiene_acta_prefectura'] as int) == 1,
      );
    });
  }

  // --- Cache de Candidatos ---

  Future<void> cacheCandidatos(String dignidad, List<Map<String, dynamic>> candidatos) async {
    final db = await appDatabase.database;
    await db.transaction((txn) async {
      await txn.delete('candidatos_local', where: 'dignidad = ?', whereArgs: [dignidad]);

      for (final candidato in candidatos) {
        await txn.insert('candidatos_local', {
          'id': candidato['id'],
          'nombre_candidato': candidato['nombre_candidato'],
          'organizacion_politica': candidato['organizacion_politica'],
          'dignidad': candidato['dignidad'],
          'lista_numero': candidato['lista_numero'],
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getCandidatosCached(String dignidad) async {
    final db = await appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'candidatos_local',
      where: 'dignidad = ?',
      whereArgs: [dignidad],
      orderBy: 'lista_numero ASC',
    );
    return List<Map<String, dynamic>>.from(maps);
  }

  // --- CRUD Actas Local ---

  Future<void> guardarActaLocal({
    required String localId, // uuid
    required String mesaId,
    required String dignidad,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    required double latitud,
    required double longitud,
    required String? fotoLocalPath,
    required String? fotoUrl,
    required List<Map<String, dynamic>> votos,
    required SyncStatus status,
    String? remoteId,
    bool corregida = false,
  }) async {
    final db = await appDatabase.database;
    
    await db.transaction((txn) async {
      final now = DateTime.now().toUtc().toIso8601String();
      await txn.insert('actas_local', {
        'id': localId,
        'mesa_id': mesaId,
        'dignidad': dignidad,
        'votos_blancos': votosBlancos,
        'votos_nulos': votosNulos,
        'total_sufragantes': totalSufragantes,
        'latitud': latitud,
        'longitud': longitud,
        'foto_local_path': fotoLocalPath,
        'foto_url': fotoUrl,
        'corregida': corregida ? 1 : 0,
        'created_at': now,
        'updated_at': now,
        'remote_id': remoteId,
        'sync_status': status.toDb(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Insertar votos
      print('=== LOG TEMPORAL 3: GUARDANDO VOTOS OFFLINE ===');
      print('Votos recibidos en el parámetro (acta \$localId): \${votos.length}');
      
      for (final voto in votos) {
        await txn.insert('votos_candidatos_local', {
          'id': const Uuid().v4(), // id verdaderamente único
          'acta_local_id': localId,
          'candidato_id': voto['candidato_id'],
          'cantidad': voto['cantidad'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Verificando filas insertadas
      final insertedRows = await txn.rawQuery('SELECT COUNT(*) as count FROM votos_candidatos_local WHERE acta_local_id = ?', [localId]);
      print("Votos guardados exitosamente en la BD para esta acta: \${insertedRows.first['count']}");
      print('==================================================');


      // Actualizar el estado de la mesa local para reflejar que tiene acta
      final columnToUpdate = dignidad == 'alcaldia' ? 'tiene_acta_alcaldia' : 'tiene_acta_prefectura';
      await txn.rawUpdate(
        'UPDATE mesas_local SET $columnToUpdate = 1 WHERE id = ?',
        [mesaId]
      );
    });
  }

  Future<void> actualizarActaLocal({
    required String localId,
    required int votosBlancos,
    required int votosNulos,
    required int totalSufragantes,
    String? fotoLocalPath,
    String? fotoUrl,
    required List<Map<String, dynamic>> votos,
    required SyncStatus status,
    required bool corregida,
  }) async {
    if (localId.isEmpty) {
      throw ArgumentError('El localId no puede estar vacío en actualizarActaLocal');
    }
    
    final db = await appDatabase.database;
    
    await db.transaction((txn) async {
      final updateData = <String, dynamic>{
        'votos_blancos': votosBlancos,
        'votos_nulos': votosNulos,
        'total_sufragantes': totalSufragantes,
        'corregida': corregida ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': status.toDb(),
      };
      
      if (fotoLocalPath != null) updateData['foto_local_path'] = fotoLocalPath;
      if (fotoUrl != null) updateData['foto_url'] = fotoUrl;

      await txn.update('actas_local', updateData, where: 'id = ?', whereArgs: [localId]);

      // Limpiar votos anteriores y reinsertar
      await txn.delete('votos_candidatos_local', where: 'acta_local_id = ?', whereArgs: [localId]);
      
      for (final voto in votos) {
        await txn.insert('votos_candidatos_local', {
          'id': const Uuid().v4(), // id verdaderamente único
          'acta_local_id': localId,
          'candidato_id': voto['candidato_id'],
          'cantidad': voto['cantidad'],
        });
      }
    });
  }

  Future<void> eliminarActaLocal(String localId, SyncStatus status) async {
    final db = await appDatabase.database;
    
    // Leer acta para saber qué mesa y dignidad es
    final actas = await db.query('actas_local', where: 'id = ?', whereArgs: [localId]);
    if (actas.isNotEmpty) {
      final acta = actas.first;
      final mesaId = acta['mesa_id'] as String;
      final dignidad = acta['dignidad'] as String;
      
      if (status == SyncStatus.pendingDelete) {
        // Solo marcar para borrar luego (si ya estaba sincronizado remotamente)
        await db.update('actas_local', {'sync_status': status.toDb()}, where: 'id = ?', whereArgs: [localId]);
      } else {
        // Borrado físico (si era pendingCreate y no se subió, lo borramos de una vez)
        await db.delete('actas_local', where: 'id = ?', whereArgs: [localId]);
        await db.delete('votos_candidatos_local', where: 'acta_local_id = ?', whereArgs: [localId]);
        
        // Actualizar el estado de la mesa local para reflejar que ya no tiene el acta
        final columnToUpdate = dignidad == 'alcaldia' ? 'tiene_acta_alcaldia' : 'tiene_acta_prefectura';
        await db.rawUpdate(
          'UPDATE mesas_local SET $columnToUpdate = 0 WHERE id = ?',
          [mesaId]
        );
      }
    }
  }

  // Obtener una acta específica local por remoteId
  Future<Map<String, dynamic>?> getActaLocalByRemoteId(String remoteId) async {
    final db = await appDatabase.database;
    final actas = await db.query('actas_local', where: 'remote_id = ?', whereArgs: [remoteId]);
    if (actas.isEmpty) return null;
    return actas.first;
  }
  
  // Obtener una acta específica local por localId
  Future<Map<String, dynamic>?> getActaLocalById(String localId) async {
    final db = await appDatabase.database;
    final actas = await db.query('actas_local', where: 'id = ?', whereArgs: [localId]);
    if (actas.isEmpty) return null;
    return actas.first;
  }
  
  // Obtener todas las actas de una mesa para combinarlas con el servidor
  Future<List<Map<String, dynamic>>> getMisActasLocal(String mesaId) async {
    final db = await appDatabase.database;
    final actas = await db.query('actas_local', where: 'mesa_id = ?', whereArgs: [mesaId]);
    
    List<Map<String, dynamic>> resultado = [];
    
    for (final acta in actas) {
      final String localId = acta['id'] as String;
      final votosRows = await db.rawQuery('''
        SELECT v.*, c.nombre_candidato, c.organizacion_politica, c.dignidad 
        FROM votos_candidatos_local v
        LEFT JOIN candidatos_local c ON v.candidato_id = c.id
        WHERE v.acta_local_id = ?
      ''', [localId]);
      
      final Map<String, dynamic> mutableActa = Map<String, dynamic>.from(acta);
      mutableActa['votos_candidatos'] = votosRows.map((row) => {
        'cantidad': row['cantidad'],
        'candidato_id': row['candidato_id'],
        'candidatos': {
          'id': row['candidato_id'],
          'nombre_candidato': row['nombre_candidato'],
          'organizacion_politica': row['organizacion_politica'],
          'dignidad': row['dignidad'],
        }
      }).toList();
      resultado.add(mutableActa);
    }
    
    return resultado;
  }

  // Obtener pendientes (pendingCreate, pendingUpdate, pendingDelete)
  Future<List<Map<String, dynamic>>> getActasPendientesSync() async {
    final db = await appDatabase.database;
    final statuses = [
      SyncStatus.pendingCreate.toDb(), 
      SyncStatus.pendingUpdate.toDb(), 
      SyncStatus.pendingDelete.toDb()
    ];
    
    final placeholders = List.filled(statuses.length, '?').join(',');
    final actas = await db.query('actas_local', where: 'sync_status IN ($placeholders)', whereArgs: statuses);
    
    List<Map<String, dynamic>> resultado = [];
    for (final acta in actas) {
      final String localId = acta['id'] as String;
      final votosRows = await db.rawQuery('''
        SELECT v.*, c.nombre_candidato, c.organizacion_politica, c.dignidad 
        FROM votos_candidatos_local v
        LEFT JOIN candidatos_local c ON v.candidato_id = c.id
        WHERE v.acta_local_id = ?
      ''', [localId]);
      
      final Map<String, dynamic> mutableActa = Map<String, dynamic>.from(acta);
      mutableActa['votos_candidatos'] = votosRows.map((row) => {
        'cantidad': row['cantidad'],
        'candidato_id': row['candidato_id'],
        'candidatos': {
          'id': row['candidato_id'],
          'nombre_candidato': row['nombre_candidato'],
          'organizacion_politica': row['organizacion_politica'],
          'dignidad': row['dignidad'],
        }
      }).toList();
      resultado.add(mutableActa);
    }
    return resultado;
  }

  Future<void> marcarComoSincronizada(String localId, {String? remoteId, String? fotoUrl, required String serverUpdatedAt}) async {
    final db = await appDatabase.database;
    final Map<String, dynamic> update = {
      'sync_status': SyncStatus.synced.toDb(),
      'foto_local_path': null, // Ya se subió
      'updated_at': serverUpdatedAt, // Actualizar con el timestamp del servidor para futuras ediciones
    };
    if (remoteId != null) update['remote_id'] = remoteId;
    if (fotoUrl != null) update['foto_url'] = fotoUrl;
    
    await db.update('actas_local', update, where: 'id = ?', whereArgs: [localId]);
  }

  Future<void> borrarActaFisicamente(String localId) async {
    final db = await appDatabase.database;
    await db.delete('votos_candidatos_local', where: 'acta_local_id = ?', whereArgs: [localId]);
    await db.delete('actas_local', where: 'id = ?', whereArgs: [localId]);
  }

  // Manejo de Conflictos
  Future<void> marcarComoConflicto(String localId, String serverSnapshotJson) async {
    final db = await appDatabase.database;
    await db.update('actas_local', {
      'sync_status': SyncStatus.conflict.toDb(),
      'server_snapshot': serverSnapshotJson,
    }, where: 'id = ?', whereArgs: [localId]);
  }

  Future<List<Map<String, dynamic>>> getActasEnConflicto() async {
    final db = await appDatabase.database;
    final actas = await db.query('actas_local', where: 'sync_status = ?', whereArgs: [SyncStatus.conflict.toDb()]);
    
    List<Map<String, dynamic>> resultado = [];
    for (final acta in actas) {
      final String localId = acta['id'] as String;
      final votosRows = await db.rawQuery('''
        SELECT v.*, c.nombre_candidato, c.organizacion_politica, c.dignidad 
        FROM votos_candidatos_local v
        LEFT JOIN candidatos_local c ON v.candidato_id = c.id
        WHERE v.acta_local_id = ?
      ''', [localId]);
      
      final Map<String, dynamic> mutableActa = Map<String, dynamic>.from(acta);
      mutableActa['votos_candidatos'] = votosRows.map((row) => {
        'cantidad': row['cantidad'],
        'candidato_id': row['candidato_id'],
        'candidatos': {
          'id': row['candidato_id'],
          'nombre_candidato': row['nombre_candidato'],
          'organizacion_politica': row['organizacion_politica'],
          'dignidad': row['dignidad'],
        }
      }).toList();
      resultado.add(mutableActa);
    }
    return resultado;
  }
}
