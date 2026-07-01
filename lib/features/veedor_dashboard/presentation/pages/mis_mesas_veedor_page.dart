import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_snackbar.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';
import 'seleccionar_dignidad_page.dart';

class MisMesasVeedorPage extends StatefulWidget {
  const MisMesasVeedorPage({super.key});

  @override
  State<MisMesasVeedorPage> createState() => _MisMesasVeedorPageState();
}

class _MisMesasVeedorPageState extends State<MisMesasVeedorPage> {
  @override
  void initState() {
    super.initState();
    context.read<VeedorBloc>().add(InitVeedorEvent());
  }

  Future<void> _onRefresh() async {
    context.read<VeedorBloc>().add(InitVeedorEvent());
    // Esperar un momento para que el RefreshIndicator se muestre animado
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VeedorBloc, VeedorState>(
      listenWhen: (previous, current) {
        return (previous.successMessage != current.successMessage && current.successMessage != null) ||
            (previous.errorMessage != current.errorMessage && current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.successMessage != null) {
          FeedbackSnackbar.showSuccess(context, state.successMessage!);
        } else if (state.errorMessage != null) {
          FeedbackSnackbar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.mesas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        Widget content;
        if (state.mesas.isEmpty) {
          content = CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_bar, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes mesas asignadas.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          content = ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: state.mesas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final mesa = state.mesas[index];

              final Color bordeColor;
              if (mesa.tieneAmbasActas) {
                bordeColor = AppTheme.flagBlue;
              } else if (mesa.tieneActaAlcaldia || mesa.tieneActaPrefectura) {
                bordeColor = AppTheme.flagYellow;
              } else {
                bordeColor = AppTheme.flagRed;
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: bordeColor, width: 4)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(left: 10, right: 6, top: 0, bottom: 0),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF0F4FA),
                        child: Icon(Icons.table_chart, color: AppTheme.flagBlue),
                      ),
                      title: Text('Mesa N°${mesa.numeroMesa}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(mesa.recintoNombre, style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: _buildStatusChip('Alcaldía', mesa.tieneActaAlcaldia),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                fit: FlexFit.loose,
                                child: _buildStatusChip('Prefectura', mesa.tieneActaPrefectura),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<VeedorBloc>(),
                              child: SeleccionarDignidadPage(mesa: mesa),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: content,
        );
      },
    );
  }

  Widget _buildStatusChip(String title, bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDone ? Colors.green.shade200 : Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.pending,
            size: 12,
            color: isDone ? Colors.green : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '$title ${isDone ? '✓' : 'pendiente'}',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontSize: 10,
                color: isDone ? Colors.green.shade700 : Colors.grey.shade700,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
