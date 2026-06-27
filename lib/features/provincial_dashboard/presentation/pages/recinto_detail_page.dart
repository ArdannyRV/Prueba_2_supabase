import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recinto_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../widgets/asignar_coordinador_dialog.dart';

class RecintoDetailPage extends StatefulWidget {
  final RecintoEntity recinto;

  const RecintoDetailPage({super.key, required this.recinto});

  @override
  State<RecintoDetailPage> createState() => _RecintoDetailPageState();
}

class _RecintoDetailPageState extends State<RecintoDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProvincialBloc>().stream.listen((state) {
        if (state.successMessage != null &&
            state.successMessage!.toLowerCase().contains('asignado') &&
            mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  void _showAsignarCoordinadorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: AsignarCoordinadorDialog(recintoId: widget.recinto.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recinto = widget.recinto;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.flagBlue,
        foregroundColor: Colors.white,
        title: Text(
          recinto.nombre,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                  Text('Detalles del Recinto', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${recinto.parroquia}, ${recinto.canton}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('${recinto.mesasConActa} / ${recinto.totalMesas} mesas registradas', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (recinto.coordinadorId == null)
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAsignarCoordinadorDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.flagBlue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Asignar Coordinador', style: TextStyle(fontSize: 12)),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Coordinador Asignado', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(recinto.coordinadorNombre ?? 'Nombre no disponible', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Desasignar Coordinador'),
                                    content: const Text('¿Desasignar a este coordinador del recinto? El usuario no será eliminado del sistema.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: Text('Desasignar', style: TextStyle(color: Colors.red.shade700)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && context.mounted) {
                                  context.read<ProvincialBloc>().add(DesasignarCoordinadorEvent(recintoId: recinto.id));
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.person_remove, size: 18),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade300),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              label: const Text('Desasignar', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppTheme.borderColor),
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: mesa.tieneActa ? AppTheme.flagBlue : Colors.grey.shade400, width: 3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: mesa.tieneActa ? Colors.green.shade100 : Colors.grey.shade200,
                        child: Icon(
                          mesa.tieneActa ? Icons.check : Icons.inbox,
                          color: mesa.tieneActa ? Colors.green.shade700 : Colors.grey.shade600,
                        ),
                      ),
                      title: Text('Mesa ${mesa.numeroMesa}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: mesa.tieneActa ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                mesa.tieneActa ? 'Con acta' : 'Pendiente',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: mesa.tieneActa ? Colors.green.shade800 : Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            if (mesa.tieneActa) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'GPS: ${mesa.latitud?.toStringAsFixed(5) ?? 'N/A'}, ${mesa.longitud?.toStringAsFixed(5) ?? 'N/A'}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue.shade700, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: mesa.tieneActa ? const Icon(Icons.receipt_long, color: Colors.green) : null,
                    ),
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
