import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_snackbar.dart';
import '../../domain/entities/mesa_veedor_entity.dart';
import '../../data/datasources/veedor_remote_data_source.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';

class CapturaEvidenciaPage extends StatefulWidget {
  final MesaVeedorEntity mesa;
  final String dignidad;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;
  final List<Map<String, dynamic>> votos;

  const CapturaEvidenciaPage({
    super.key,
    required this.mesa,
    required this.dignidad,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    required this.votos,
  });

  @override
  State<CapturaEvidenciaPage> createState() => _CapturaEvidenciaPageState();
}

class _CapturaEvidenciaPageState extends State<CapturaEvidenciaPage> {
  File? _foto;
  bool _validandoNitidez = false;
  double? _nitidezScore;
  bool _guardando = false;

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
    setState(() => _guardando = true);
    try {
      // Solicitar permisos de GPS si no los tiene
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Los permisos de ubicación están denegados permanentemente');
      }

      // GPS
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Subir foto
      final ds = VeedorRemoteDataSource(Supabase.instance.client);
      final bytes = await _foto!.readAsBytes();
      final fotoUrl = await ds.subirFoto(widget.mesa.id, widget.dignidad, bytes);

      if (mounted) {
        // Registrar acta via BLoC
        context.read<VeedorBloc>().add(RegistrarActaEvent(
          mesaId: widget.mesa.id,
          dignidad: widget.dignidad,
          fotoUrl: fotoUrl,
          votosBlancos: widget.votosBlancos,
          votosNulos: widget.votosNulos,
          totalSufragantes: widget.totalSufragantes,
          latitud: pos.latitude,
          longitud: pos.longitude,
          votos: widget.votos,
        ));

        // Note: Instead of doing Navigator pop immediately here, 
        // normally we should wait for bloc state, but we will just trust it
        // and navigate back to dashboard, the bloc listener on MisMesasVeedorPage 
        // will show the success message.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        FeedbackSnackbar.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _foto != null && _nitidezScore != null && _nitidezScore! >= 150.0 && !_guardando;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencia fotográfica'),
        backgroundColor: AppTheme.flagBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Toma una foto clara del acta de escrutinio firmada.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _foto == null
                  ? Container(
                      height: 300,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Toca el botón para fotografiar el acta',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : Image.file(
                      _foto!,
                      height: 300,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_foto == null ? 'Cámara' : 'Retomar'),
                    onPressed: _guardando ? null : _tomarFoto,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.flagBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    onPressed: _guardando ? null : _abrirGaleria,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.flagBlue, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_validandoNitidez)
              Column(
                children: [
                  const LinearProgressIndicator(color: AppTheme.flagBlue),
                  const SizedBox(height: 8),
                  Text('Validando nitidez...', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            if (_nitidezScore != null && !_validandoNitidez)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _nitidezScore! >= 50 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _nitidezScore! >= 50 ? Colors.green.shade200 : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _nitidezScore! >= 50 ? Icons.check_circle : Icons.error,
                        color: _nitidezScore! >= 50 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nitidez: ${_nitidezScore!.toStringAsFixed(1)} / 100',
                        style: TextStyle(
                          color: _nitidezScore! >= 50 ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: canSave ? _guardar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.flagYellow,
                  foregroundColor: AppTheme.flagBlue,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _guardando
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Subiendo acta...'),
                        ],
                      )
                    : const Text(
                        'Guardar acta',
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

