import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/feedback_snackbar.dart';
import '../../domain/entities/mesa_veedor_entity.dart';
import '../../data/datasources/veedor_remote_data_source.dart';
import '../bloc/veedor_bloc.dart';
import 'captura_evidencia_page.dart';

class RegistroActaPage extends StatefulWidget {
  final MesaVeedorEntity mesa;
  final String dignidad;

  const RegistroActaPage({super.key, required this.mesa, required this.dignidad});

  @override
  State<RegistroActaPage> createState() => _RegistroActaPageState();
}

class _RegistroActaPageState extends State<RegistroActaPage> {
  List<Map<String, dynamic>> _candidatos = [];
  final List<TextEditingController> _votosControllers = [];
  
  final _blancosCtrl = TextEditingController();
  final _nulosCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCandidatos();
  }

  Future<void> _cargarCandidatos() async {
    try {
      final ds = VeedorRemoteDataSource(Supabase.instance.client);
      final candidatos = await ds.getCandidatos(widget.dignidad);
      if (mounted) {
        setState(() {
          _candidatos = candidatos;
          _votosControllers.addAll(
            List.generate(candidatos.length, (_) => TextEditingController()),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        FeedbackSnackbar.showError(context, 'Error al cargar candidatos: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _votosControllers) {
      ctrl.dispose();
    }
    _blancosCtrl.dispose();
    _nulosCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  void _validarYContinuar() {
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

    // Construir lista de votos para pasar a la siguiente pantalla
    final votos = List.generate(_candidatos.length, (i) => {
      'candidato_id': _candidatos[i]['id'],
      'cantidad': int.tryParse(_votosControllers[i].text) ?? 0,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<VeedorBloc>(),
          child: CapturaEvidenciaPage(
            mesa: widget.mesa,
            dignidad: widget.dignidad,
            votosBlancos: blancos,
            votosNulos: nulos,
            totalSufragantes: total,
            votos: votos,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acta de ${widget.dignidad == 'alcaldia' ? 'Alcaldía' : 'Prefectura'}'),
        backgroundColor: AppTheme.flagBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Votos por candidato',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_candidatos.length, (i) {
                    final candidato = _candidatos[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(candidato['nombre_candidato'] ?? ''),
                        subtitle: Text('Lista ${candidato['lista_numero']} - ${candidato['organizacion_politica']}'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _votosControllers[i],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                          ),
                        ),
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
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
                          const Divider(height: 32),
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.flagBlue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _validarYContinuar,
                      child: const Text(
                        'Siguiente → Capturar evidencia',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
