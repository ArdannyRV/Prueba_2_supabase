import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recinto_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../widgets/create_coordinador_dialog.dart';

class RecintoDetailPage extends StatelessWidget {
  final RecintoEntity recinto;

  const RecintoDetailPage({super.key, required this.recinto});

  void _showCreateCoordinadorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: CreateCoordinadorDialog(recintoId: recinto.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          recinto.nombre,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalles del Recinto', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${recinto.parroquia}, ${recinto.canton}', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${recinto.mesasConActa} / ${recinto.totalMesas} mesas registradas', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (recinto.coordinadorId == null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCreateCoordinadorDialog(context),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Asignar Coordinador'),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Este recinto ya tiene un coordinador asignado.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green.shade800, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mesa = recinto.mesas[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: mesa.tieneActa ? Colors.green.shade100 : Colors.grey.shade200,
                        child: Icon(
                          mesa.tieneActa ? Icons.check : Icons.inbox,
                          color: mesa.tieneActa ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                      ),
                      title: Text('Mesa ${mesa.numeroMesa}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: mesa.tieneActa
                          ? Text(
                              'GPS: ${mesa.latitud?.toStringAsFixed(5) ?? 'N/A'}, ${mesa.longitud?.toStringAsFixed(5) ?? 'N/A'}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
                            )
                          : Text('Sin acta registrada', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      trailing: mesa.tieneActa ? const Icon(Icons.receipt_long, color: Colors.green) : null,
                    ),
                  );
                },
                childCount: recinto.mesas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
