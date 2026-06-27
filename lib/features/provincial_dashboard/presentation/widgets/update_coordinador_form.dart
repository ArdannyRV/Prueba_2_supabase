import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/coordinador_entity.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../../../../core/theme/app_theme.dart';

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Actualizar Coordinador',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.flagBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(height: 2, width: 40, color: AppTheme.flagYellow),
                ),
              ],
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
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.flagBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
