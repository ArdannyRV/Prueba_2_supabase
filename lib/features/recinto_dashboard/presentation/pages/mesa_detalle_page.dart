import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/recinto_coord_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/mesa_detalle_entity.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';
import '../bloc/recinto_coord_state.dart';

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
              const SizedBox(height: 12),
              _buildTotalesCard(
                mesa.votosBlaancosAlcaldia ?? 0,
                mesa.votosNulosAlcaldia ?? 0,
                mesa.totalSufragantesAlcaldia ?? 0,
              ),
              const SizedBox(height: 24),
            ],

            // Prefectura
            if (mesa.votosPrefectura.isNotEmpty) ...[
              Text('Prefectura', style: textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildFoto(mesa.fotoUrlPrefectura),
              const SizedBox(height: 12),
              _buildTablaVotos(mesa.votosPrefectura),
              const SizedBox(height: 12),
              _buildTotalesCard(
                mesa.votosBlaancosPrefectura ?? 0,
                mesa.votosNulosPrefectura ?? 0,
                mesa.totalSufragantesPrefectura ?? 0,
              ),
              const SizedBox(height: 24),
            ],
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

  Widget _buildTotalesCard(int blancos, int nulos, int total) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTotalRow('Votos Blancos', blancos),
            const Divider(),
            _buildTotalRow('Votos Nulos', nulos),
            const Divider(),
            _buildTotalRow('Total Sufragantes', total, bold: true),
          ],
        ),
      ),
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
  
  late TextEditingController _blancosPrefCtrl;
  late TextEditingController _nulosPrefCtrl;
  late TextEditingController _totalPrefCtrl;
  
  final Map<String, TextEditingController> _votosCtrls = {};
  
  File? _fotoAlcaldia;
  File? _fotoPrefectura;
  double? _nitidezAlcaldia;
  double? _nitidezPrefectura;
  bool _validandoAlcaldia = false;
  bool _validandoPrefectura = false;
  bool _subiendoFoto = false;
  
  @override
  void initState() {
    super.initState();
    _blancosCtrl = TextEditingController(text: '${widget.mesa.votosBlaancosAlcaldia ?? 0}');
    _nulosCtrl = TextEditingController(text: '${widget.mesa.votosNulosAlcaldia ?? 0}');
    _totalCtrl = TextEditingController(text: '${widget.mesa.totalSufragantesAlcaldia ?? 0}');
    
    _blancosPrefCtrl = TextEditingController(text: '${widget.mesa.votosBlaancosPrefectura ?? 0}');
    _nulosPrefCtrl = TextEditingController(text: '${widget.mesa.votosNulosPrefectura ?? 0}');
    _totalPrefCtrl = TextEditingController(text: '${widget.mesa.totalSufragantesPrefectura ?? 0}');
    
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
    _blancosPrefCtrl.dispose();
    _nulosPrefCtrl.dispose();
    _totalPrefCtrl.dispose();
    for (var ctrl in _votosCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  static bool _calcularNitidezIsolate(String imagePath) {
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
      return (varianceSum / laplacianValues.length) >= 150.0;
    } catch (e) {
      return false;
    }
  }

  Future<void> _procesarFotoParaDignidad(File foto, String dignidad) async {
    final esAlcaldia = dignidad == 'alcaldia';
    setState(() {
      if (esAlcaldia) { _fotoAlcaldia = foto; _validandoAlcaldia = true; _nitidezAlcaldia = null; }
      else { _fotoPrefectura = foto; _validandoPrefectura = true; _nitidezPrefectura = null; }
    });
    final bool isSharp = await compute(_calcularNitidezIsolate, foto.path);
    if (mounted) {
      setState(() {
        if (esAlcaldia) { _nitidezAlcaldia = isSharp ? 200.0 : 0.0; _validandoAlcaldia = false; }
        else { _nitidezPrefectura = isSharp ? 200.0 : 0.0; _validandoPrefectura = false; }
      });
      if (!isSharp && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Foto muy borrosa. Por favor toma una imagen más nítida.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _tomarFotoParaDignidad(String dignidad) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    await _procesarFotoParaDignidad(File(picked.path), dignidad);
  }

  Future<void> _abrirGaleriaParaDignidad(String dignidad) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    await _procesarFotoParaDignidad(File(picked.path), dignidad);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _subiendoFoto = true);
    try {
      final ds = RecintoCoordRemoteDataSource(Supabase.instance.client);

      // Subir foto alcaldía si existe y es nítida
      String? fotoUrlAlcaldia;
      if (_fotoAlcaldia != null && (_nitidezAlcaldia ?? 0) >= 150.0
          && widget.mesa.actaIdAlcaldia != null) {
        final bytes = await _fotoAlcaldia!.readAsBytes();
        fotoUrlAlcaldia = await ds.subirFotoActa(
          mesaId: widget.mesa.id, dignidad: 'alcaldia', bytes: bytes);
      }

      // Subir foto prefectura si existe y es nítida
      String? fotoUrlPrefectura;
      if (_fotoPrefectura != null && (_nitidezPrefectura ?? 0) >= 150.0
          && widget.mesa.actaIdPrefectura != null) {
        final bytes = await _fotoPrefectura!.readAsBytes();
        fotoUrlPrefectura = await ds.subirFotoActa(
          mesaId: widget.mesa.id, dignidad: 'prefectura', bytes: bytes);
      }

      // Corregir acta alcaldía
      if (widget.mesa.actaIdAlcaldia != null) {
        await ds.corregirActaPorDignidad(
          actaId: widget.mesa.actaIdAlcaldia!,
          votosBlancos: int.parse(_blancosCtrl.text),
          votosNulos: int.parse(_nulosCtrl.text),
          totalSufragantes: int.parse(_totalCtrl.text),
          fotoUrl: fotoUrlAlcaldia,
          votos: widget.mesa.votosAlcaldia.map((voto) {
            final candId = voto['candidato_id'].toString();
            return {'candidato_id': voto['candidato_id'],
                    'cantidad': int.tryParse(_votosCtrls[candId]?.text ?? '0') ?? 0};
          }).toList(),
        );
      }

      // Corregir acta prefectura
      if (widget.mesa.actaIdPrefectura != null) {
        await ds.corregirActaPorDignidad(
          actaId: widget.mesa.actaIdPrefectura!,
          votosBlancos: int.parse(_blancosPrefCtrl.text),
          votosNulos: int.parse(_nulosPrefCtrl.text),
          totalSufragantes: int.parse(_totalPrefCtrl.text),
          fotoUrl: fotoUrlPrefectura,
          votos: widget.mesa.votosPrefectura.map((voto) {
            final candId = voto['candidato_id'].toString();
            return {'candidato_id': voto['candidato_id'],
                    'cantidad': int.tryParse(_votosCtrls[candId]?.text ?? '0') ?? 0};
          }).toList(),
        );
      }

      if (mounted) {
        context.read<RecintoCoordBloc>().add(const FetchMesasEvent());
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Acta corregida correctamente'),
            backgroundColor: Colors.amber.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _subiendoFoto = false);
    }
  }

  Widget _buildFotoSection(String dignidad) {
    final esAlcaldia = dignidad == 'alcaldia';
    final foto = esAlcaldia ? _fotoAlcaldia : _fotoPrefectura;
    final score = esAlcaldia ? _nitidezAlcaldia : _nitidezPrefectura;
    final validando = esAlcaldia ? _validandoAlcaldia : _validandoPrefectura;
    final label = esAlcaldia ? 'Alcaldía' : 'Prefectura';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actualizar imagen acta $label',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        const Text('Solo si la anterior era ilegible.',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        if (foto != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.file(foto, height: 140, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Cámara', style: TextStyle(fontSize: 12)),
                onPressed: _subiendoFoto ? null : () => _tomarFotoParaDignidad(dignidad),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.photo_library, size: 16),
                label: const Text('Galería', style: TextStyle(fontSize: 12)),
                onPressed: _subiendoFoto ? null : () => _abrirGaleriaParaDignidad(dignidad),
              ),
            ),
          ],
        ),
        if (validando) ...[
          const SizedBox(height: 6),
          const LinearProgressIndicator(),
          const SizedBox(height: 4),
          const Text('Validando nitidez...', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
        if (foto != null && score != null && score < 150.0) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
            const SizedBox(width: 4),
            const Expanded(child: Text('Imagen de baja calidad. Toma una más nítida.',
                style: TextStyle(color: Colors.red, fontSize: 11))),
          ]),
        ],
      ],
    );
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

                    // ── ALCALDÍA ──────────────────────────────
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
                            Expanded(flex: 2,
                              child: Text('${voto['nombre_candidato']}',
                                  style: const TextStyle(fontSize: 12))),
                            const SizedBox(width: 12),
                            Expanded(flex: 1,
                              child: TextFormField(
                                controller: _votosCtrls[candId],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                                validator: (v) => v!.isEmpty ? 'Req.' : null,
                              )),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _blancosCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Blancos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _nulosCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Nulos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _totalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Total'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFotoSection('alcaldia'),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    // ── PREFECTURA ────────────────────────────
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
                            Expanded(flex: 2,
                              child: Text('${voto['nombre_candidato']}',
                                  style: const TextStyle(fontSize: 12))),
                            const SizedBox(width: 12),
                            Expanded(flex: 1,
                              child: TextFormField(
                                controller: _votosCtrls[candId],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                                validator: (v) => v!.isEmpty ? 'Req.' : null,
                              )),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _blancosPrefCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Blancos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _nulosPrefCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Nulos'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                        const SizedBox(width: 8),
                        Expanded(child: TextFormField(controller: _totalPrefCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Total'),
                            validator: (v) => v!.isEmpty ? 'Req.' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFotoSection('prefectura'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            BlocListener<RecintoCoordBloc, RecintoCoordState>(
              listenWhen: (prev, curr) =>
                  prev.successMessage != curr.successMessage ||
                  prev.errorMessage != curr.errorMessage,
              listener: (context, state) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.amber.shade700,
                    ),
                  );
                } else if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: ElevatedButton(
                onPressed: _subiendoFoto ? null : _submit,
                child: _subiendoFoto
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 8),
                          Text('Guardando...'),
                        ],
                      )
                    : const Text('Guardar Corrección'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
