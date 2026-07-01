import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/veedor_bloc.dart';
import '../bloc/veedor_event.dart';

class ConflictoActaSheet extends StatelessWidget {
  final Map<String, dynamic> actaLocal;

  const ConflictoActaSheet({super.key, required this.actaLocal});

  @override
  Widget build(BuildContext context) {
    final String serverSnapshotStr = actaLocal['server_snapshot'] ?? '{}';
    Map<String, dynamic> actaServidor = {};
    try {
      actaServidor = jsonDecode(serverSnapshotStr) as Map<String, dynamic>;
    } catch (_) {}

    final List localVotos = actaLocal['votos_candidatos'] ?? [];
    final List serverVotos = actaServidor['votos_candidatos'] ?? [];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conflicto de Sincronización',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'El acta fue modificada por otro coordinador o existe un conflicto. Revisa las diferencias y decide qué versión mantener.',
            style: TextStyle(color: Colors.black87),
          ),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDiffRow('Votos Blancos', actaLocal['votos_blancos'], actaServidor['votos_blancos']),
                  _buildDiffRow('Votos Nulos', actaLocal['votos_nulos'], actaServidor['votos_nulos']),
                  _buildDiffRow('Total Sufragantes', actaLocal['total_sufragantes'], actaServidor['total_sufragantes']),
                  const SizedBox(height: 16),
                  const Text('Votos por Candidato:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...localVotos.map((vLocal) {
                    final candidatoId = vLocal['candidato_id'];
                    final vServer = serverVotos.firstWhere((vs) => vs['candidato_id'] == candidatoId, orElse: () => {'cantidad': 0});
                    
                    return _buildDiffRow(
                      'Candidato ID: \${candidatoId.toString().substring(0,4)}...', // simplificación
                      vLocal['cantidad'],
                      vServer['cantidad'],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: const Text('Forzar mis cambios locales'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.flagBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<VeedorBloc>().add(ResolverConflictoEvent(
                actaLocalId: actaLocal['id'],
                mantenerLocal: true,
              ));
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Descartar y usar los del servidor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: () {
              context.read<VeedorBloc>().add(ResolverConflictoEvent(
                actaLocalId: actaLocal['id'],
                mantenerLocal: false,
              ));
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDiffRow(String label, dynamic localVal, dynamic serverVal) {
    final esDiferente = localVal != serverVal;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: esDiferente ? Colors.orange.shade50 : Colors.grey.shade50,
        border: Border.all(color: esDiferente ? Colors.orange.shade200 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text('Local: $localVal', 
                  style: TextStyle(
                    color: esDiferente ? Colors.orange.shade800 : Colors.black87,
                    fontWeight: esDiferente ? FontWeight.bold : FontWeight.normal,
                  )),
              ),
              Expanded(
                child: Text('Servidor: $serverVal', 
                  style: TextStyle(
                    color: esDiferente ? Colors.blue.shade800 : Colors.black87,
                  )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
