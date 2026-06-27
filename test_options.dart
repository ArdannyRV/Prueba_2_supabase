import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final secClient3 = SupabaseClient(
    'dummy',
    'dummy',
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
    ),
  );
}
