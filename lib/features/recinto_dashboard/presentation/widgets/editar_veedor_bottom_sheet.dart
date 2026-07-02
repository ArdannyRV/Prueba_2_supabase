import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/nombre_validator.dart';
import '../../../../core/utils/telefono_validator.dart';
import '../../domain/entities/veedor_entity.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';

class EditarVeedorBottomSheet extends StatefulWidget {
  final VeedorEntity veedor;

  const EditarVeedorBottomSheet({super.key, required this.veedor});

  @override
  State<EditarVeedorBottomSheet> createState() => _EditarVeedorBottomSheetState();
}

class _EditarVeedorBottomSheetState extends State<EditarVeedorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _cedulaCtrl;
  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _correoCtrl;

  @override
  void initState() {
    super.initState();
    _cedulaCtrl = TextEditingController(text: widget.veedor.cedula);
    _nombresCtrl = TextEditingController(text: widget.veedor.nombres);
    _apellidosCtrl = TextEditingController(text: widget.veedor.apellidos);
    _telefonoCtrl = TextEditingController(text: widget.veedor.telefono);
    _correoCtrl = TextEditingController(text: widget.veedor.correo);
  }

  @override
  void dispose() {
    _cedulaCtrl.dispose();
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RecintoCoordBloc>().add(
      ActualizarVeedorEvent(
        id: widget.veedor.id,
        nombres: _nombresCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Veedor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.flagBlue,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(height: 2, width: 40, color: AppTheme.flagYellow),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _cedulaCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Cédula',
                prefixIcon: Icon(Icons.badge_outlined),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombresCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombres',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (!NombreValidator.validar(v)) return 'Solo se permiten letras';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _apellidosCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (!NombreValidator.validar(v)) return 'Solo se permiten letras';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              maxLength: TelefonoValidator.longitudExacta,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (!TelefonoValidator.validar(v)) {
                  return 'Debe tener exactamente ${TelefonoValidator.longitudExacta} dígitos numéricos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _correoCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Actualizar Veedor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
