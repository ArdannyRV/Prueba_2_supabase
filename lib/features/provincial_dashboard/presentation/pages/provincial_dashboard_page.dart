import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_recinto_bottom_sheet.dart';
import 'recinto_detail_page.dart';

class ProvincialDashboardPage extends StatefulWidget {
  const ProvincialDashboardPage({super.key});

  @override
  State<ProvincialDashboardPage> createState() => _ProvincialDashboardPageState();
}

class _ProvincialDashboardPageState extends State<ProvincialDashboardPage> {
  late ProvincialBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProvincialBloc>()..add(const FetchRecintosEvent());
  }

  void _logout() {
    context.read<AuthBloc>().add(const SignOutRequested());
  }

  void _showCreateRecintoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: const CreateRecintoBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _bloc,
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<ProvincialBloc, ProvincialState>(
            listener: (context, state) {
              if (state is ProvincialActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ));
              } else if (state is ProvincialActionError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              } else if (state is ProvincialError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.indigo.shade700,
            title: Text(
              'Panel Provincial',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
          body: BlocBuilder<ProvincialBloc, ProvincialState>(
            builder: (context, state) {
              if (state is ProvincialLoading || state is ProvincialInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ProvincialLoaded) {
                final recintos = state.recintos;

                if (recintos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No hay recintos registrados aún.',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _bloc.add(const FetchRecintosEvent());
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: recintos.length,
                    itemBuilder: (context, index) {
                      final recinto = recintos[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Icon(Icons.how_to_vote_rounded, color: Colors.indigo.shade700),
                          ),
                          title: Text(
                            recinto.nombre,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${recinto.parroquia}, ${recinto.canton}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.pie_chart, size: 14, color: Colors.green.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recinto.mesasConActa} / ${recinto.totalMesas} mesas con acta',
                                      style: GoogleFonts.inter(
                                        color: Colors.green.shade700,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: _bloc,
                                  child: RecintoDetailPage(recinto: recinto),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }

              // Si es un estado intermedio que no contiene la lista, o un error fatal (aunque los errores se muestran por SnackBar y el estado debería volver a cargarse)
              return const Center(child: Text('Estado desconocido'));
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showCreateRecintoBottomSheet,
            backgroundColor: Colors.indigo.shade600,
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            label: Text(
              'Nuevo Recinto',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
