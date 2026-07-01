import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/database/app_database.dart';
import 'core/sync/sync_service.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize injectable
  getIt.init();

  // Inicializar DB (al inyectarla en el container forzamos su init asíncrono en db getter si se requiere).
  final db = getIt<AppDatabase>();
  await db.database;
  
  // Forzar inicialización de sync service para que escuche conectividad
  getIt<SyncService>();
}
