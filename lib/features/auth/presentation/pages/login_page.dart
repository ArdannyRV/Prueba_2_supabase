import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/flag_stripe.dart';
import '../widgets/icon_badge.dart';
import '../widgets/loading_overlay.dart';
import 'reset_password_page.dart';
import '../../../provincial_dashboard/presentation/pages/provincial_main_page.dart';
import 'change_initial_password_page.dart';
import '../../../recinto_dashboard/presentation/pages/recinto_dashboard_page.dart';
import '../../../veedor_dashboard/presentation/pages/veedor_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  String? _resolverMensajeError(String message) {
    if (message.contains('aún no ha sido confirmada')) {
      return message;
    }
    
    final msg = message.toLowerCase();
    if (msg.contains('invalid') ||
        msg.contains('credentials') ||
        msg.contains('password') ||
        msg.contains('user not found') ||
        msg.contains('email')) {
      return 'Correo o contraseña incorrectos. Por favor verifica tus datos e intenta de nuevo.';
    }
    return 'No se pudo iniciar sesión. Por favor intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.debeCambiarPass) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChangeInitialPasswordPage()),
              );
            } else {
              switch (user.rol) {
                case 'coordinador_provincial':
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ProvincialMainPage()),
                  );
                  break;
                case 'coordinador_recinto':
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RecintoDashboardPage()),
                  );
                  break;
                case 'veedor':
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const VeedorDashboardPage()),
                  );
                  break;
                default:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rol "${user.rol}" no reconocido en el sistema.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
              }
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final errorMessage = state is AuthError
              ? _resolverMensajeError(state.message)
              : null;

          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const FlagStripe(),
                        const SizedBox(height: 32),
                        const Center(child: IconBadge(icon: Icons.how_to_vote)),
                        const SizedBox(height: 24),
                        Text(
                          'Bienvenido',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inicia sesión para continuar',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Correo electrónico',
                          hint: 'tu@email.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Por favor ingresa tu correo';
                            if (!value.contains('@')) return 'Por favor ingresa un correo válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Por favor ingresa tu contraseña';
                            if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                            ),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                        color: Colors.red.shade700, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSignIn,
                            child: const Text('Iniciar sesión'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}