import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/datasources/veedor_remote_data_source.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import 'mis_mesas_veedor_page.dart';

class VeedorDashboardPage extends StatefulWidget {
  const VeedorDashboardPage({super.key});

  @override
  State<VeedorDashboardPage> createState() => _VeedorDashboardPageState();
}

class _VeedorDashboardPageState extends State<VeedorDashboardPage> {
  late final VeedorBloc _veedorBloc;

  @override
  void initState() {
    super.initState();
    _veedorBloc = VeedorBloc(VeedorRemoteDataSource(Supabase.instance.client))
      ..add(InitVeedorEvent());
  }

  @override
  void dispose() {
    _veedorBloc.close();
    super.dispose();
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
      child: BlocProvider.value(
        value: _veedorBloc,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Panel Veedor - Mis Mesas'),
            backgroundColor: AppTheme.flagBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Cerrar sesión',
                onPressed: () => context.read<AuthBloc>().add(const SignOutRequested()),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.flagYellow, AppTheme.flagRed],
                  ),
                ),
              ),
            ),
          ),
          body: const MisMesasVeedorPage(),
        ),
      ),
    );
  }
}