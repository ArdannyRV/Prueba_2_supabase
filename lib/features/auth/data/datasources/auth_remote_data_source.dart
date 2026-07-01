import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      final Map<String, dynamic>? perfil = await supabaseClient
          .from('perfiles')
          .select('*')
          .eq('id', response.user!.id)
          .maybeSingle();

      final rol = perfil?['rol'] as String?;
      final debeCambiarPass = perfil?['debe_cambiar_pass'] as bool? ?? false;

      final prefs = await SharedPreferences.getInstance();
      if (rol != null) await prefs.setString('cached_rol', rol);
      await prefs.setBool('cached_debe_cambiar_pass', debeCambiarPass);

      return UserModel.fromSupabaseUser(
        response.user!,
        rol: rol,
        debeCambiarPass: debeCambiarPass,
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user == null) {
        throw Exception('No se pudo crear la cuenta');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al enviar email de recuperación: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_rol');
      await prefs.remove('cached_debe_cambiar_pass');
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Consultar el perfil
      String? rol;
      bool debeCambiarPass = false;
      final prefs = await SharedPreferences.getInstance();

      try {
        final Map<String, dynamic>? perfil = await supabaseClient
            .from('perfiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();

        rol = perfil?['rol'] as String?;
        debeCambiarPass = perfil?['debe_cambiar_pass'] as bool? ?? false;

        if (rol != null) await prefs.setString('cached_rol', rol);
        await prefs.setBool('cached_debe_cambiar_pass', debeCambiarPass);
      } catch (_) {
        // Fallback a caché local si no hay conexión
        rol = prefs.getString('cached_rol');
        debeCambiarPass = prefs.getBool('cached_debe_cambiar_pass') ?? false;
      }

      return UserModel.fromSupabaseUser(
        user,
        rol: rol,
        debeCambiarPass: debeCambiarPass,
      );
    } catch (e) {
      throw Exception('Error al obtener usuario actual: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }
}
