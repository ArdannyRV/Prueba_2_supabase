import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/mesa_veedor_entity.dart';
import '../bloc/veedor_bloc.dart';
import 'registro_acta_page.dart';
import 'mis_actas_page.dart';

class SeleccionarDignidadPage extends StatelessWidget {
  final MesaVeedorEntity mesa;

  const SeleccionarDignidadPage({super.key, required this.mesa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa N°${mesa.numeroMesa}'),
        backgroundColor: AppTheme.flagBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selecciona el acta a registrar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildDignidadCard(
              context,
              title: 'Acta de Alcaldía',
              isDone: mesa.tieneActaAlcaldia,
              dignidad: 'alcaldia',
            ),
            const SizedBox(height: 16),
            _buildDignidadCard(
              context,
              title: 'Acta de Prefectura',
              isDone: mesa.tieneActaPrefectura,
              dignidad: 'prefectura',
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Ver actas registradas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<VeedorBloc>(),
                      child: MisActasPage(mesa: mesa),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDignidadCard(BuildContext context, {required String title, required bool isDone, required String dignidad}) {
    return InkWell(
      onTap: () {
        if (isDone) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<VeedorBloc>(),
                child: MisActasPage(mesa: mesa, dignidadInicial: dignidad),
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<VeedorBloc>(),
                child: RegistroActaPage(mesa: mesa, dignidad: dignidad),
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                Icons.how_to_vote,
                size: 40,
                color: isDone ? Colors.grey.shade400 : AppTheme.flagBlue,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDone ? Colors.green.shade200 : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        isDone ? 'Registrada ✓' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
