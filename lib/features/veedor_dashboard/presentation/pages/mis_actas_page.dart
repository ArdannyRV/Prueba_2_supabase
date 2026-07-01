import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_snackbar.dart';
import '../../domain/entities/mesa_veedor_entity.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';
import '../bloc/veedor_state.dart';
import '../../../../core/sync/sync_status.dart';
import '../widgets/conflicto_acta_sheet.dart';

class MisActasPage extends StatefulWidget {
  final MesaVeedorEntity mesa;
  final String? dignidadInicial; // Usado para scroll o highlight en el futuro

  const MisActasPage({super.key, required this.mesa, this.dignidadInicial});

  @override
  State<MisActasPage> createState() => _MisActasPageState();
}

class _MisActasPageState extends State<MisActasPage> {
  @override
  void initState() {
    super.initState();
    context.read<VeedorBloc>().add(FetchMisActasEvent(widget.mesa.id));
  }

  void _showCorregirActaSheet(BuildContext context, Map<String, dynamic> acta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<VeedorBloc>(),
        child: CorregirActaBottomSheet(mesa: widget.mesa, acta: acta),
      ),
    );
  }

  void _showEliminarActaDialog(BuildContext context, Map<String, dynamic> acta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<VeedorBloc>(),
        child: _EliminarActaDialog(mesa: widget.mesa, acta: acta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VeedorBloc, VeedorState>(
      listenWhen: (prev, current) =>
          (prev.successMessage != current.successMessage && current.successMessage != null) ||
          (prev.errorMessage != current.errorMessage && current.errorMessage != null),
      listener: (context, state) {
        if (state.successMessage != null) {
          FeedbackSnackbar.showSuccess(context, state.successMessage!);
          // Refresh list after success
          context.read<VeedorBloc>().add(FetchMisActasEvent(widget.mesa.id));
        } else if (state.errorMessage != null) {
          FeedbackSnackbar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final actas = widget.dignidadInicial != null
            ? state.actasActuales.where((a) => a['dignidad'] == widget.dignidadInicial).toList()
            : state.actasActuales;
            
        // Si hay conflictos en esta mesa (que aún no se hayan mergeado a actasActuales), 
        // los mostramos en la lista de arriba si es que la UI actual no los metió allí por getMisActasLocal
        final List<Map<String, dynamic>> actasTotales = List.from(actas);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.dignidadInicial != null
                ? (widget.dignidadInicial == 'alcaldia' ? 'Acta de Alcaldía' : 'Acta de Prefectura')
                : 'Actas Registradas'),
            backgroundColor: AppTheme.flagBlue,
            foregroundColor: Colors.white,
          ),
          body: state.isLoading && actas.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : actas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay actas registradas para esta mesa.',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: actasTotales.length,
                      itemBuilder: (context, index) {
                        final acta = actasTotales[index];
                        final bool corregida = acta['corregida'] == 1 || acta['corregida'] == true;
                        final List votos = acta['votos_candidatos'] ?? [];
                        final fotoUrl = acta['foto_url'];
                        final fotoLocalPath = acta['foto_local_path'];
                        final bool hasLocalPhoto = fotoLocalPath != null && File(fotoLocalPath).existsSync();
                        final String syncStatusStr = acta['sync_status'] ?? SyncStatus.synced.toDb();
                        final bool isConflict = syncStatusStr == SyncStatus.conflict.toDb();
                        final bool isPending = syncStatusStr.startsWith('pending');

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      acta['dignidad'] == 'alcaldia' ? 'Alcaldía' : 'Prefectura',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.flagBlue,
                                          ),
                                    ),
                                    if (isConflict)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Text(
                                          '¡Conflicto!',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade800,
                                          ),
                                        ),
                                      )
                                    else if (isPending)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.yellow.shade400),
                                        ),
                                        child: Text(
                                          'Pendiente',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.yellow.shade900,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Text(
                                          'Sincronizada',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: corregida ? Colors.orange.shade50 : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: corregida ? Colors.orange.shade200 : Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        corregida ? 'Corregida' : 'Original',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: corregida ? Colors.orange.shade800 : Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (acta['latitud'] != null && acta['longitud'] != null)
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        'GPS: ${(acta['latitud'] as num).toStringAsFixed(6)}, ${(acta['longitud'] as num).toStringAsFixed(6)}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                if (hasLocalPhoto)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(fotoLocalPath!),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                  )
                                else if (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${acta['foto_url']}?t=${DateTime.now().millisecondsSinceEpoch}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                  ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStat('Blancos', acta['votos_blancos'].toString()),
                                    _buildStat('Nulos', acta['votos_nulos'].toString()),
                                    _buildStat('Total', acta['total_sufragantes'].toString(), isTotal: true),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                Text(
                                  'Votos por candidato',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                ...votos.map((v) {
                                  final candidato = v['candidatos'];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            candidato['nombre_candidato'] ?? '',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            v['cantidad'].toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 16),
                                    if (isConflict)
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                        label: const Text('Resolver Conflicto', style: TextStyle(color: Colors.orange)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.orange),
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (_) => BlocProvider.value(
                                              value: context.read<VeedorBloc>(),
                                              child: ConflictoActaSheet(actaLocal: acta),
                                            ),
                                          );
                                        },
                                      )
                                    else
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Corregir esta acta'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.flagBlue,
                                          side: const BorderSide(color: AppTheme.flagBlue),
                                        ),
                                        onPressed: () => _showCorregirActaSheet(context, acta),
                                      ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                                      label: const Text('Eliminar acta', style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                      onPressed: () => _showEliminarActaDialog(context, acta),
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, {bool isTotal = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.flagRed : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class CorregirActaBottomSheet extends StatefulWidget {
  final MesaVeedorEntity mesa;
  final Map<String, dynamic> acta;

  const CorregirActaBottomSheet({super.key, required this.mesa, required this.acta});

  @override
  State<CorregirActaBottomSheet> createState() => _CorregirActaBottomSheetState();
}

class _CorregirActaBottomSheetState extends State<CorregirActaBottomSheet> {
  late final TextEditingController _blancosCtrl;
  late final TextEditingController _nulosCtrl;
  late final TextEditingController _totalCtrl;
  final List<TextEditingController> _votosControllers = [];
  late final List _votosOriginales;
  
  File? _foto;
  bool _validandoNitidez = false;
  double? _nitidezScore;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _blancosCtrl = TextEditingController(text: widget.acta['votos_blancos'].toString());
    _nulosCtrl = TextEditingController(text: widget.acta['votos_nulos'].toString());
    _totalCtrl = TextEditingController(text: widget.acta['total_sufragantes'].toString());
    
    _votosOriginales = widget.acta['votos_candidatos'] ?? [];
    for (final v in _votosOriginales) {
      _votosControllers.add(TextEditingController(text: v['cantidad'].toString()));
    }
  }

  @override
  void dispose() {
    _blancosCtrl.dispose();
    _nulosCtrl.dispose();
    _totalCtrl.dispose();
    for (final c in _votosControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _validandoNitidez = true;
      _foto = File(picked.path);
      _nitidezScore = null;
    });

    final bool isSharp = await compute(_calcularNitidezIsolate, _foto!.path);
    
    if (mounted) {
      setState(() {
        _nitidezScore = isSharp ? 200.0 : 0.0; // 200 = pasa, 0 = falla
        _validandoNitidez = false;
      });

      if (!isSharp) {
        FeedbackSnackbar.showError(context,
          'Foto muy borrosa o pixeleada. Por favor toma otra más nítida.');
      } else {
        FeedbackSnackbar.showSuccess(context, 'Foto aceptada ✓');
      }
    }
  }

  Future<void> _abrirGaleria() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _validandoNitidez = true;
      _foto = File(picked.path);
      _nitidezScore = null;
    });

    final bool isSharp = await compute(_calcularNitidezIsolate, _foto!.path);

    if (mounted) {
      setState(() {
        _nitidezScore = isSharp ? 200.0 : 0.0; // 200 = pasa, 0 = falla
        _validandoNitidez = false;
      });

      if (!isSharp) {
        FeedbackSnackbar.showError(context,
          'Foto muy borrosa o pixeleada. Por favor toma otra más nítida.');
      } else {
        FeedbackSnackbar.showSuccess(context, 'Foto aceptada ✓');
      }
    }
  }

  Future<void> _guardar() async {
    final totalVotosCandidatos = _votosControllers.fold(0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));
    final blancos = int.tryParse(_blancosCtrl.text) ?? 0;
    final nulos = int.tryParse(_nulosCtrl.text) ?? 0;
    final total = int.tryParse(_totalCtrl.text) ?? 0;

    final sumaTotal = totalVotosCandidatos + blancos + nulos;

    if (sumaTotal != total) {
      FeedbackSnackbar.showError(context, 'Error matemático: la suma de votos ($sumaTotal) no coincide con el total de sufragantes ($total)');
      return;
    }
    if (total == 0) {
      FeedbackSnackbar.showError(context, 'El total de sufragantes no puede ser 0');
      return;
    }

    setState(() => _guardando = true);
    
    try {
      final votos = List.generate(_votosOriginales.length, (i) => {
        'candidato_id': _votosOriginales[i]['candidatos']['id'],
        'cantidad': int.tryParse(_votosControllers[i].text) ?? 0,
      });

      if (mounted) {
        context.read<VeedorBloc>().add(CorregirActaVeedorEvent(
          actaOriginal: widget.acta,
          actaLocalId: widget.acta['id'],
          votosBlancos: blancos,
          votosNulos: nulos,
          totalSufragantes: total,
          fotoLocalPath: _foto?.path,
          votos: votos,
        ));
        context.read<VeedorBloc>().add(FetchMisActasEvent(widget.mesa.id));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        FeedbackSnackbar.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Corregir Acta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.flagBlue,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Votos por candidato',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_votosOriginales.length, (i) {
                      final candidato = _votosOriginales[i]['candidatos'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(candidato['nombre_candidato'] ?? ''),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _votosControllers[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    Text(
                      'Totales',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Text('Votos blancos')),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _blancosCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Text('Votos nulos')),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _nulosCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total de sufragantes',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _totalCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: AppTheme.flagBlue, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Evidencia fotográfica (Opcional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Solo toma una nueva foto si la anterior era ilegible.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (_foto != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_foto!, height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text(
                              'Cámara',
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            onPressed: _tomarFoto,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text(
                              'Galería',
                              style: TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            onPressed: _abrirGaleria,
                          ),
                        ),
                      ],
                    ),
                    if (_foto != null && _nitidezScore != null && _nitidezScore! < 150.0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Imagen de baja calidad. Por favor toma o sube una imagen más nítida y legible.',
                                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_validandoNitidez)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _guardando 
                    ? null 
                    : (_foto != null && (_nitidezScore == null || _nitidezScore! < 150.0)) 
                        ? null 
                        : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.flagYellow,
                  foregroundColor: AppTheme.flagBlue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _guardando
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Guardar corrección',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EliminarActaDialog extends StatefulWidget {
  final MesaVeedorEntity mesa;
  final Map<String, dynamic> acta;
  const _EliminarActaDialog({required this.mesa, required this.acta});

  @override
  State<_EliminarActaDialog> createState() => _EliminarActaDialogState();
}

class _EliminarActaDialogState extends State<_EliminarActaDialog> {
  int _segundos = 10;
  bool _puedeConfirmar = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundos <= 1) {
        t.cancel();
        setState(() { _segundos = 0; _puedeConfirmar = true; });
      } else {
        setState(() => _segundos--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dignidadLabel = widget.acta['dignidad'] == 'alcaldia' ? 'Alcaldía' : 'Prefectura';
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('¿Estás seguro?', style: TextStyle(color: Colors.red)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vas a eliminar permanentemente el Acta de $dignidadLabel de la Mesa N°${widget.mesa.numeroMesa}, incluyendo todos los votos y la fotografía.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (!_puedeConfirmar)
            Center(
              child: Column(
                children: [
                  Text(
                    '$_segundos',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Text('segundos para confirmar',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _puedeConfirmar
              ? () {
                  context.read<VeedorBloc>().add(EliminarActaVeedorEvent(
                    actaLocalId: widget.acta['id'],
                    mesaId: widget.mesa.id,
                    dignidad: widget.acta['dignidad'],
                  ));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            _puedeConfirmar ? 'Sí, eliminar' : 'Espera...',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

bool _calcularNitidezIsolate(String imagePath) {
  try {
    final bytes = File(imagePath).readAsBytesSync();
    final img.Image? decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return false;

    final img.Image grayscale = img.grayscale(decodedImage);
    final img.Image small = img.copyResize(grayscale, width: 400);

    final int width = small.width;
    final int height = small.height;

    double sum = 0.0;
    List<double> laplacianValues = [];

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final num top    = small.getPixel(x, y - 1).r;
        final num bottom = small.getPixel(x, y + 1).r;
        final num left   = small.getPixel(x - 1, y).r;
        final num right  = small.getPixel(x + 1, y).r;
        final num center = small.getPixel(x, y).r;

        final double laplacian = (top + bottom + left + right - (4 * center)).toDouble();
        laplacianValues.add(laplacian);
        sum += laplacian;
      }
    }

    if (laplacianValues.isEmpty) return false;

    final double mean = sum / laplacianValues.length;
    double varianceSum = 0.0;
    for (final val in laplacianValues) {
      varianceSum += (val - mean) * (val - mean);
    }
    final double variance = varianceSum / laplacianValues.length;

    return variance >= 150.0;
  } catch (e) {
    return false;
  }
}
