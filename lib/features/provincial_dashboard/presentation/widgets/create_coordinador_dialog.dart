import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class CreateCoordinadorDialog extends StatefulWidget {
  final String recintoId;

  const CreateCoordinadorDialog({super.key, required this.recintoId});

  @override
  State<CreateCoordinadorDialog> createState() => _CreateCoordinadorDialogState();
}

class _CreateCoordinadorDialogState extends State<CreateCoordinadorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  String? _selectedCoordinadorId;
  bool _isCreatingNew = true;

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const FetchUnassignedCoordinadoresEvent());
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isCreatingNew) {
      if (!_formKey.currentState!.validate()) return;
      context.read<ProvincialBloc>().add(CreateCoordinadorEvent(
            recintoId: widget.recintoId,
            cedula: _cedulaController.text.trim(),
            nombres: _nombresController.text.trim(),
            apellidos: _apellidosController.text.trim(),
            telefono: _telefonoController.text.trim(),
            correo: _correoController.text.trim(),
          ));
    } else {
      if (_selectedCoordinadorId == null) return;
      context.read<ProvincialBloc>().add(
        AsignarCoordinadorEvent(
          recintoId: widget.recintoId,
          coordinadorId: _selectedCoordinadorId!,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      titlePadding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      title: Text('Asignar Coordinador de Recinto', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<ProvincialBloc, ProvincialState>(
                builder: (context, state) {
                  final coordinadores = state.unassignedCoordinadores;
                  final isEmpty = coordinadores == null || coordinadores.isEmpty;
                  
                  return DropdownButtonFormField<String?>(
                    value: _selectedCoordinadorId,
                    decoration: InputDecoration(
                      labelText: isEmpty ? 'No hay vacantes disponibles' : 'Seleccionar Existente o Crear Nuevo',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('+ Crear Nuevo Coordinador', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      if (!isEmpty)
                        ...coordinadores.map((coordinador) {
                          return DropdownMenuItem<String?>(
                            value: coordinador.id,
                            child: Text('${coordinador.nombres} ${coordinador.apellidos} - ${coordinador.cedula}'),
                          );
                        }),
                    ],
                    onChanged: isEmpty ? null : (value) {
                      setState(() {
                        _selectedCoordinadorId = value;
                        _isCreatingNew = value == null;
                      });
                    },
                  );
                },
              ),
              if (_isCreatingNew) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _cedulaController,
                        decoration: const InputDecoration(labelText: 'Cédula', prefixIcon: Icon(Icons.badge)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!CedulaValidator.validar(v)) return 'Cédula inválida';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nombresController,
                        decoration: const InputDecoration(labelText: 'Nombres', prefixIcon: Icon(Icons.person)),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _apellidosController,
                        decoration: const InputDecoration(labelText: 'Apellidos', prefixIcon: Icon(Icons.person_outline)),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo', prefixIcon: Icon(Icons.email)),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Asignar', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
