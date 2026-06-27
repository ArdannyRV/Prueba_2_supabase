import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class AsignarCoordinadorDialog extends StatefulWidget {
  final String recintoId;

  const AsignarCoordinadorDialog({super.key, required this.recintoId});

  @override
  State<AsignarCoordinadorDialog> createState() => _AsignarCoordinadorDialogState();
}

class _AsignarCoordinadorDialogState extends State<AsignarCoordinadorDialog> {
  String? _selectedCoordinadorId;

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const FetchUnassignedCoordinadoresEvent());
  }

  void _asignar() {
    if (_selectedCoordinadorId != null) {
      context.read<ProvincialBloc>().add(
        AsignarCoordinadorEvent(
          recintoId: widget.recintoId,
          coordinadorId: _selectedCoordinadorId!,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Coordinador'),
      content: BlocBuilder<ProvincialBloc, ProvincialState>(
        builder: (context, state) {
          final coordinadores = state.unassignedCoordinadores;
          
          if (state.isLoading && coordinadores.isEmpty) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (coordinadores.isEmpty) {
            return const Text('No hay vacantes.');
          }

          return DropdownButtonFormField<String>(
            value: _selectedCoordinadorId,
            hint: const Text('Selecciona un coordinador'),
            isExpanded: true,
            items: coordinadores.map((coordinador) {
              return DropdownMenuItem(
                value: coordinador.id,
                child: Text('${coordinador.nombres} ${coordinador.apellidos}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCoordinadorId = value;
              });
            },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedCoordinadorId == null ? null : _asignar,
          child: const Text('Asignar'),
        ),
      ],
    );
  }
}
