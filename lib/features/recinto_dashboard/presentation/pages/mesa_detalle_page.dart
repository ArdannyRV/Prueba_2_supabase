import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/mesa_detalle_entity.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';

class MesaDetallePage extends StatefulWidget {
  final MesaDetalleEntity mesa;

  const MesaDetallePage({super.key, required this.mesa});

  @override
  State<MesaDetallePage> createState() => _MesaDetallePageState();
}

class _MesaDetallePageState extends State<MesaDetallePage> {
  void _mostrarFormCorreccion(BuildContext context) {
    // Aquí idealmente mostraríamos un modal con los datos actuales
    // Por simplicidad en la instrucción, usaremos un bottom sheet.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RecintoCoordBloc>(),
        child: _FormCorreccionActa(mesa: widget.mesa),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesa = widget.mesa;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa N°${mesa.numeroMesa}'),
        backgroundColor: AppTheme.flagBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info general
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Veedor asignado', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(mesa.veedorNombre ?? 'Ninguno', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text('Estado del acta', style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(
                      mesa.corregida == true ? 'Registrada y corregida' : 'Registrada',
                      style: textTheme.titleSmall?.copyWith(color: AppTheme.successColor),
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

            // Alcaldía
            if (mesa.votosAlcaldia.isNotEmpty) ...[
              Text('Alcaldía', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFoto(mesa.fotoUrlAlcaldia),
              const SizedBox(height: 12),
              _buildTablaVotos(mesa.votosAlcaldia),
              const SizedBox(height: 24),
            ],

            // Prefectura
            if (mesa.votosPrefectura.isNotEmpty) ...[
              Text('Prefectura', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFoto(mesa.fotoUrlPrefectura),
              const SizedBox(height: 12),
              _buildTablaVotos(mesa.votosPrefectura),
              const SizedBox(height: 24),
            ],

            // Totales
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

            // Botón corregir
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => _mostrarFormCorreccion(context),
                child: const Text('Corregir datos del acta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFoto(String? url) {
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
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            )
          : const Center(
              child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            ),
    );
  }

  Widget _buildTablaVotos(List<Map<String, dynamic>> votos) {
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
        border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade200)),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFF7F8FA)),
            children: [
              Padding(padding: EdgeInsets.all(8.0), child: Text('Candidato', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Lista/Org.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Votos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.right)),
            ],
          ),
          ...votos.map((voto) {
            return TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8.0), child: Text(voto['nombre_candidato'] ?? '', style: const TextStyle(fontSize: 12))),
                Padding(padding: const EdgeInsets.all(8.0), child: Text(voto['organizacion_politica'] ?? '', style: const TextStyle(fontSize: 12))),
                Padding(padding: const EdgeInsets.all(8.0), child: Text('${voto['cantidad']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            );
          }),
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

class _FormCorreccionActa extends StatefulWidget {
  final MesaDetalleEntity mesa;

  const _FormCorreccionActa({required this.mesa});

  @override
  State<_FormCorreccionActa> createState() => _FormCorreccionActaState();
}

class _FormCorreccionActaState extends State<_FormCorreccionActa> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _blancosCtrl;
  late TextEditingController _nulosCtrl;
  late TextEditingController _totalCtrl;
  
  final Map<String, TextEditingController> _votosCtrls = {};
  
  @override
  void initState() {
    super.initState();
    _blancosCtrl = TextEditingController(text: '${widget.mesa.votosBlancos ?? 0}');
    _nulosCtrl = TextEditingController(text: '${widget.mesa.votosNulos ?? 0}');
    _totalCtrl = TextEditingController(text: '${widget.mesa.totalSufragantes ?? 0}');
    
    final todosLosVotos = [
      ...widget.mesa.votosAlcaldia,
      ...widget.mesa.votosPrefectura
    ];
    for (var voto in todosLosVotos) {
      final candId = voto['candidato_id'].toString();
      _votosCtrls[candId] =
          TextEditingController(text: '${voto['cantidad'] ?? 0}');
    }
  }

  @override
  void dispose() {
    _blancosCtrl.dispose();
    _nulosCtrl.dispose();
    _totalCtrl.dispose();
    for (var ctrl in _votosCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    if (widget.mesa.actaId == null) return;

    final todosLosVotos = [
      ...widget.mesa.votosAlcaldia,
      ...widget.mesa.votosPrefectura
    ];
    final nuevosVotos = todosLosVotos.map((voto) {
      final candId = voto['candidato_id'].toString();
      final cant = int.tryParse(_votosCtrls[candId]?.text ?? '0') ?? 0;
      return {'candidato_id': voto['candidato_id'], 'cantidad': cant};
    }).toList();

    context.read<RecintoCoordBloc>().add(CorregirActaEvent(
      actaId: widget.mesa.actaId!,
      votosBlancos: int.parse(_blancosCtrl.text),
      votosNulos: int.parse(_nulosCtrl.text),
      totalSufragantes: int.parse(_totalCtrl.text),
      votos: nuevosVotos,
    ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Corregir Acta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.flagBlue),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Volver',
                ),
              ],
            ),
            Center(
              child: Container(height: 2, width: 40, color: AppTheme.flagYellow),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Votos por Candidato',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 12),

                    // Alcaldía
                    const Text('Alcaldía',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,
                            color: AppTheme.flagBlue)),
                    const SizedBox(height: 8),
                    ...widget.mesa.votosAlcaldia.map((voto) {
                      final candId = voto['candidato_id'].toString();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('${voto['nombre_candidato']}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _votosCtrls[candId],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12)),
                                validator: (v) => v!.isEmpty ? 'Req.' : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Prefectura
                    const Text('Prefectura',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12,
                            color: AppTheme.flagBlue)),
                    const SizedBox(height: 8),
                    ...widget.mesa.votosPrefectura.map((voto) {
                      final candId = voto['candidato_id'].toString();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text('${voto['nombre_candidato']}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: _votosCtrls[candId],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12)),
                                validator: (v) => v!.isEmpty ? 'Req.' : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Blancos, Nulos, Total
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _blancosCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Blancos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _nulosCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Nulos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _totalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Total'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Guardar Corrección'),
            ),
          ],
        ),
      ),
    );
  }
}
