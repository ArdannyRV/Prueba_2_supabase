import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/flag_stripe.dart';
import '../widgets/icon_badge.dart';
import 'login_page.dart';
import '../../../../core/widgets/feedback_snackbar.dart';
import '../../../provincial_dashboard/presentation/pages/provincial_main_page.dart';
import '../../../recinto_dashboard/presentation/pages/recinto_dashboard_page.dart';
import '../../../veedor_dashboard/presentation/pages/veedor_dashboard_page.dart';

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

      // Obtener el rol para redirigir correctamente
      final perfil = await supabase
          .from('perfiles')
          .select('rol')
          .eq('id', userId)
          .single();

      final rol = perfil['rol'] as String?;

      if (mounted) {
        FeedbackSnackbar.showSuccess(context, '¡Contraseña actualizada exitosamente!');
        await Future.delayed(const Duration(milliseconds: 800));
      }

      if (mounted) {
        Widget destino;
        switch (rol) {
          case 'coordinador_provincial':
            destino = const ProvincialMainPage();
            break;
          case 'coordinador_recinto':
            destino = const RecintoDashboardPage();
            break;
          case 'veedor':
            destino = const VeedorDashboardPage();
            break;
          default:
            destino = const LoginPage();
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => destino),
          (route) => false,
        );
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
        FeedbackSnackbar.showError(context, msg);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          context.read<AuthBloc>().add(const SignOutRequested());
        }
      }
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}