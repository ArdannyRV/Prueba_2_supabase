import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/mesa_entity.dart';
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
                      border: Border(left: BorderSide(color: mesa.tieneActa ? AppTheme.flagBlue : AppTheme.flagYellow, width: 3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: InkWell(
                      onTap: mesa.tieneActa
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MesaDetalleProvincialPage(mesa: mesa),
                                ),
                              )
                          : null,
                      borderRadius: BorderRadius.circular(6),
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
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                if (mesa.veedorNombre != null && mesa.veedorNombre!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 12, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          mesa.veedorNombre!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: mesa.tieneActa ? const Icon(Icons.receipt_long, color: Colors.green) : null,
                        ),
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

class MesaDetalleProvincialPage extends StatelessWidget {
  final MesaEntity mesa;
  const MesaDetalleProvincialPage({super.key, required this.mesa});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa N°${mesa.numeroMesa}'),
        backgroundColor: AppTheme.flagBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veedor asignado',
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(mesa.veedorNombre ?? 'Ninguno', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text('Estado del acta',
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(
                      mesa.corregida == true ? 'Registrada y corregida' : 'Registrada',
                      style: textTheme.titleSmall?.copyWith(color: Colors.green),
                    ),
                    if (mesa.latitudAlcaldia != null && mesa.longitudAlcaldia != null) ...[
                      const SizedBox(height: 8),
                      Text('Ubicación GPS - Alcaldía',
                          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text('${mesa.latitudAlcaldia}, ${mesa.longitudAlcaldia}',
                          style: textTheme.bodySmall),
                    ],
                    if (mesa.latitudPrefectura != null && mesa.longitudPrefectura != null) ...[
                      const SizedBox(height: 8),
                      Text('Ubicación GPS - Prefectura',
                          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                      const SizedBox(height: 2),
                      Text('${mesa.latitudPrefectura}, ${mesa.longitudPrefectura}',
                          style: textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (mesa.votosAlcaldia.isNotEmpty) ...[
              Text('Alcaldía', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFoto(context, mesa.fotoUrlAlcaldia),
              const SizedBox(height: 12),
              _buildTablaVotos(context, mesa.votosAlcaldia),
              const SizedBox(height: 24),
            ],

            if (mesa.votosPrefectura.isNotEmpty) ...[
              Text('Prefectura', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFoto(context, mesa.fotoUrlPrefectura),
              const SizedBox(height: 12),
              _buildTablaVotos(context, mesa.votosPrefectura),
              const SizedBox(height: 24),
            ],

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildTotalRow('Votos Blancos', mesa.votosBlancos ?? 0),
                    const Divider(),
                    _buildTotalRow('Votos Nulos', mesa.votosNulos ?? 0),
                    const Divider(),
                    _buildTotalRow('Total Sufragantes', mesa.totalSufragantes ?? 0, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFoto(BuildContext context, String? url) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: url != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                '$url?t=${DateTime.now().millisecondsSinceEpoch}',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
    );
  }

  Widget _buildTablaVotos(BuildContext context, List<Map<String, dynamic>> votos) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: IntrinsicColumnWidth(),
        },
        border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade200)),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFF7F8FA)),
            children: [
              Padding(padding: EdgeInsets.all(8), child: Text('Candidato', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Lista/Org.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8), child: Text('Votos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
            ],
          ),
          ...votos.map((voto) => TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(8), child: Text(voto['nombre_candidato'] ?? '', style: const TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text(voto['organizacion_politica'] ?? '', style: const TextStyle(fontSize: 12))),
              Padding(padding: const EdgeInsets.all(8), child: Text('${voto['cantidad']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
        Text('$value', style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
