import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_recinto_bottom_sheet.dart';
import 'recinto_detail_page.dart';

class RecintosListPage extends StatelessWidget {
  const RecintosListPage({super.key});

  void _showCreateRecintoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: const CreateRecintoBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProvincialBloc>();

    return BlocListener<ProvincialBloc, ProvincialState>(
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state.isLoading && state.recintos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

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
                bloc.add(const FetchRecintosEvent());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: recintos.length,
                itemBuilder: (context, index) {
                  final recinto = recintos[index];

                  return Dismissible(
                    key: Key(recinto.id),
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
                          title: const Text('Eliminar recinto'),
                          content: Text('¿Estás seguro de eliminar "${recinto.nombre}"? Esta acción no se puede deshacer.'),
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
                      bloc.add(DeleteRecintoEvent(recintoId: recinto.id));
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
                          child: Icon(Icons.how_to_vote_rounded, size: 16, color: AppTheme.primaryColor),
                        ),
                        title: Text(
                          recinto.nombre,
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
                                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${recinto.parroquia}, ${recinto.canton}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Builder(builder: (context) {
                                Color statusColor;
                                if (recinto.mesasConActa == 0) {
                                  statusColor = Colors.orange.shade700;
                                } else if (recinto.mesasConActa == recinto.totalMesas) {
                                  statusColor = const Color(0xFF1B7A3D);
                                } else {
                                  statusColor = const Color(0xFF00308F);
                                }
                                return Row(
                                  children: [
                                    Icon(Icons.pie_chart, size: 14, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recinto.mesasConActa} / ${recinto.totalMesas} mesas con acta',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: RecintoDetailPage(recinto: recinto),
                              ),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateRecintoBottomSheet(context),
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.add_business_rounded, color: Colors.white),
          label: Text(
            'Nuevo Recinto',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
