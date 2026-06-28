import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/flag_stripe.dart';
import '../widgets/icon_badge.dart';
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

  void _goBackToLogin() {
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      final userId = supabase.auth.currentUser!.id;
      await supabase
          .from('perfiles')
          .update({'debe_cambiar_pass': false})
          .eq('id', userId);

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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Franja tricolor igual que login
                  const FlagStripe(),
                  const SizedBox(height: 16),

                  // Flecha volver (esquina izquierda)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _loading ? null : _goBackToLogin,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                      label: const Text('Volver al login'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ícono igual que login
                  const Center(
                    child: IconBadge(icon: Icons.lock_reset_rounded),
                  ),
                  const SizedBox(height: 24),

                  // Título estilo login
                  Text(
                    'Cambiar contraseña',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por seguridad, debes establecer una nueva contraseña antes de continuar.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Campo nueva contraseña
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

                  // Campo confirmar
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

                  // Error message
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],

                  // Botón confirmar
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirmar nueva contraseña'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}