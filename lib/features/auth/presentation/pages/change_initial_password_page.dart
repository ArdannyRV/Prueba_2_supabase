import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class ChangeInitialPasswordPage extends StatefulWidget {
  const ChangeInitialPasswordPage({super.key});

  @override
  State<ChangeInitialPasswordPage> createState() =>
      _ChangeInitialPasswordPageState();
}

class _ChangeInitialPasswordPageState
    extends State<ChangeInitialPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final supabase = Supabase.instance.client;

      // 1. Cambiar la contraseña en Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      // 2. Marcar debe_cambiar_pass = false en perfiles
      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('perfiles')
          .update({'debe_cambiar_pass': false})
          .eq('id', userId);

      // 3. Cerrar sesión para que vuelva a loguear con la nueva contraseña
      if (mounted) {
        context.read<AuthBloc>().add(const SignOutRequested());
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Cambiar Contraseña Inicial')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset_rounded, size: 64, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'Por seguridad, debes cambiar tu contraseña antes de continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                    if (v == 'Ecuador2026') return 'No puedes reusar la contraseña inicial';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (v != _newPasswordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Cambiar contraseña'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
