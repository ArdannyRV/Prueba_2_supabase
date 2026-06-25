import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'injection_container.dart';
import 'features/auth/presentation/pages/change_initial_password_page.dart';
import 'features/provincial_dashboard/presentation/pages/provincial_dashboard_page.dart';
import 'features/recinto_dashboard/presentation/pages/recinto_dashboard_page.dart';
import 'features/veedor_dashboard/presentation/pages/veedor_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Login Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is AuthAuthenticated) {
              final user = state.user;

              // Primero: forzar cambio de contraseña si aplica
              if (user.debeCambiarPass) {
                return const ChangeInitialPasswordPage();
              }

              // Luego: redirigir según rol
              switch (user.rol) {
                case 'coordinador_provincial':
                  return const ProvincialDashboardPage();
                case 'coordinador_recinto':
                  return const RecintoDashboardPage();
                case 'veedor':
                  return const VeedorDashboardPage();
                default:
                  return WelcomePage(user: user); // fallback por si el rol es null
              }
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
