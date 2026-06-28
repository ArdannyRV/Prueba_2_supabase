import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_state.dart';
import 'mesa_detalle_page.dart';
import '../widgets/asignar_veedor_bottom_sheet.dart';

class MisMesasPage extends StatelessWidget {
  const MisMesasPage({super.key});

  void _showAsignarBottomSheet(BuildContext context, String mesaId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RecintoCoordBloc>(),
        child: AsignarVeedorBottomSheet(mesaId: mesaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecintoCoordBloc, RecintoCoordState>(
      builder: (context, state) {
        if (state.isLoading && state.mesas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.mesas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_chart_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay mesas en este recinto.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: state.mesas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final mesa = state.mesas[index];
              final hasVeedor = mesa.veedorId != null;

              return Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border(
                      left: BorderSide(
                        color: mesa.tieneActa ? AppTheme.flagBlue : AppTheme.flagRed,
                        width: 3,
                      ),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: const Icon(Icons.table_chart, size: 16, color: AppTheme.flagBlue),
                    ),
                    title: Text(
                      'Mesa N°${mesa.numeroMesa}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                hasVeedor ? mesa.veedorNombre! : 'Sin veedor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasVeedor ? Colors.black87 : AppTheme.flagRed,
                                  fontWeight: hasVeedor ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: mesa.tieneActa ? AppTheme.successColor : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            mesa.tieneActa ? 'Acta Registrada' : 'Pendiente de Acta',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: mesa.tieneActa ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showAsignarBottomSheet(context, mesa.id),
                      icon: Icon(hasVeedor ? Icons.swap_horiz : Icons.person_add, size: 16),
                      label: Text(hasVeedor ? 'Reasignar' : 'Asignar', style: const TextStyle(fontSize: 11)),
                    ),
                    onTap: () {
                      if (mesa.tieneActa) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<RecintoCoordBloc>(),
                              child: MesaDetallePage(mesa: mesa),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Esta mesa aún no tiene acta registrada')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
