import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import 'recintos_list_page.dart';
import 'coordinadores_list_page.dart';
import 'dashboard_page.dart';
import '../../../../core/theme/app_theme.dart';

class ProvincialMainPage extends StatefulWidget {
  const ProvincialMainPage({super.key});

  @override
  State<ProvincialMainPage> createState() => _ProvincialMainPageState();
}

class _ProvincialMainPageState extends State<ProvincialMainPage> {
  int _currentIndex = 0;
  late ProvincialBloc _provincialBloc;

  @override
  void initState() {
    super.initState();
    _provincialBloc = getIt<ProvincialBloc>()..add(const FetchRecintosEvent());
  }

  void _logout() {
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _provincialBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppTheme.flagBlue,
            foregroundColor: Colors.white,
            title: Text(
              _getAppBarTitle(_currentIndex),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.flagYellow, AppTheme.flagRed],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Cerrar Sesión',
                onPressed: _logout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: const [
              RecintosListPage(),
              CoordinadoresListPage(),
              DashboardPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            indicatorColor: AppTheme.flagYellow.withOpacity(0.2),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.location_city),
                label: 'Recintos',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_alt),
                label: 'Coordinadores',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart),
                label: 'Dashboard',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Panel Provincial - Recintos';
      case 1:
        return 'Panel Provincial - Coordinadores';
      case 2:
        return 'Panel Provincial - Resultados';
      default:
        return 'Panel Provincial';
    }
  }
}
