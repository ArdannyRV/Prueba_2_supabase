import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coordinador_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';

class UpdateCoordinadorForm extends StatefulWidget {
  final CoordinadorEntity coordinador;

  const UpdateCoordinadorForm({super.key, required this.coordinador});

  @override
  State<UpdateCoordinadorForm> createState() => _UpdateCoordinadorFormState();
}

class _UpdateCoordinadorFormState extends State<UpdateCoordinadorForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _telefonoCtrl;

  @override
  void initState() {
    super.initState();
    _nombresCtrl = TextEditingController(text: widget.coordinador.nombres ?? '');
    _apellidosCtrl = TextEditingController(text: widget.coordinador.apellidos ?? '');
    _telefonoCtrl = TextEditingController(text: widget.coordinador.telefono ?? '');
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProvincialBloc>().add(
            UpdateCoordinadorEvent(
              id: widget.coordinador.id,
              nombres: _nombresCtrl.text.trim(),
              apellidos: _apellidosCtrl.text.trim(),
              telefono: _telefonoCtrl.text.trim(),
            ),
          );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actualizar Coordinador',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombresCtrl,
              decoration: const InputDecoration(labelText: 'Nombres'),
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _apellidosCtrl,
              decoration: const InputDecoration(labelText: 'Apellidos'),
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Guardar Cambios'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
