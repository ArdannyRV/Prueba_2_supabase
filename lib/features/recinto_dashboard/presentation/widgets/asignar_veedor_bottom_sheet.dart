import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';
import '../bloc/recinto_coord_state.dart';

class AsignarVeedorBottomSheet extends StatelessWidget {
  final String mesaId;

  const AsignarVeedorBottomSheet({super.key, required this.mesaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecintoCoordBloc, RecintoCoordState>(
      builder: (context, state) {
        final mesa = state.mesas.firstWhere((m) => m.id == mesaId);
        final hasVeedor = mesa.veedorId != null;

        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Asignar Veedor - Mesa N°${mesa.numeroMesa}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.flagBlue),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(height: 2, width: 40, color: AppTheme.flagYellow),
              ),
              const SizedBox(height: 24),
              
              if (state.veedores.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No hay veedores registrados en el sistema.')),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: state.veedores.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final veedor = state.veedores[index];
                      final isCurrent = veedor.id == mesa.veedorId;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: isCurrent ? AppTheme.flagBlue : Colors.grey.shade200,
                          child: Icon(Icons.person, size: 16, color: isCurrent ? Colors.white : Colors.grey.shade600),
                        ),
                        title: Text(
                          veedor.nombreCompleto,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            color: isCurrent ? AppTheme.flagBlue : Colors.black87,
                          ),
                        ),
                        subtitle: Text(veedor.cedula ?? 'Sin cédula', style: const TextStyle(fontSize: 11)),
                        trailing: isCurrent 
                          ? const Icon(Icons.check_circle, color: AppTheme.flagBlue) 
                          : null,
                        onTap: () {
                          if (isCurrent) {
                            Navigator.pop(context);
                            return;
                          }
                          context.read<RecintoCoordBloc>().add(AsignarVeedorEvent(mesaId: mesaId, veedorId: veedor.id));
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                
              if (hasVeedor) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.flagRed,
                    side: const BorderSide(color: AppTheme.flagRed),
                  ),
                  onPressed: () {
                    context.read<RecintoCoordBloc>().add(DesasignarVeedorEvent(mesaId: mesaId));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.person_remove),
                  label: const Text('Desasignar veedor actual'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
