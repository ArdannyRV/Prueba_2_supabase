import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_coordinador_form.dart';
import '../widgets/update_coordinador_form.dart';
import '../../domain/entities/coordinador_entity.dart';

class CoordinadoresListPage extends StatefulWidget {
  const CoordinadoresListPage({super.key});

  @override
  State<CoordinadoresListPage> createState() => _CoordinadoresListPageState();
}

class _CoordinadoresListPageState extends State<CoordinadoresListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const FetchAllCoordinadoresEvent());
  }

  void _showCreateCoordinadorForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: const CreateCoordinadorForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProvincialBloc>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listenWhen: (previous, current) =>
            (previous.successMessage != current.successMessage && current.successMessage != null) ||
            (previous.errorMessage != current.errorMessage && current.errorMessage != null),
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ));
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ));
          }
        },
        child: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state.isLoading && state.coordinadores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final coordinadores = state.coordinadores;

          if (coordinadores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No hay coordinadores registrados.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                bloc.add(const FetchAllCoordinadoresEvent());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: coordinadores.length,
                itemBuilder: (context, index) {
                  final coordinador = coordinadores[index];

                  return Dismissible(
                    key: Key(coordinador.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar coordinador'),
                          content: Text('¿Estás seguro de eliminar a "${coordinador.nombreCompleto}"?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Eliminar', style: TextStyle(color: Colors.red.shade700)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      bloc.add(DeleteCoordinadorEvent(coordinadorId: coordinador.id));
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
                        ),
                        title: Text(
                          coordinador.nombreCompleto,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.badge, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    coordinador.cedula ?? 'Sin cédula',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    coordinador.telefono ?? 'Sin teléfono',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProvincialBloc>(),
                              child: UpdateCoordinadorForm(coordinador: coordinador),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
        },
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCoordinadorForm,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'Nuevo Coordinador',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
