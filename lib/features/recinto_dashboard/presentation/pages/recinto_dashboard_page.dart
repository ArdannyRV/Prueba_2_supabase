import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../data/datasources/recinto_coord_remote_data_source.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';
import 'mis_mesas_page.dart';
import 'mis_veedores_page.dart';

class RecintoDashboardPage extends StatefulWidget {
  const RecintoDashboardPage({super.key});

  @override
  State<RecintoDashboardPage> createState() => _RecintoDashboardPageState();
}

class _RecintoDashboardPageState extends State<RecintoDashboardPage> {
  int _currentIndex = 0;
  late final RecintoCoordBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RecintoCoordBloc(RecintoCoordRemoteDataSource(Supabase.instance.client));
    _bloc.add(const InitRecintoCoordEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentIndex == 0 ? 'Panel Recinto - Mis Mesas' : 'Panel Recinto - Mis Veedores';

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
        value: _bloc,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppTheme.flagBlue,
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
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
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              MisMesasPage(),
              MisVeedoresPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            indicatorColor: AppTheme.flagYellow.withValues(alpha: 0.2),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.table_chart), label: 'Mis Mesas'),
              NavigationDestination(icon: Icon(Icons.people), label: 'Mis Veedores'),
            ],
          ),
        ),
      ),
    );
  }
}
