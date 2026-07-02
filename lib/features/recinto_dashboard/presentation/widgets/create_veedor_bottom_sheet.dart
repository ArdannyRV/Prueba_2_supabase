import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/cedula_validator.dart';
import '../../../../core/utils/nombre_validator.dart';
import '../../../../core/utils/telefono_validator.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';

class CreateVeedorBottomSheet extends StatefulWidget {
  const CreateVeedorBottomSheet({super.key});

  @override
  State<CreateVeedorBottomSheet> createState() => _CreateVeedorBottomSheetState();
}

class _CreateVeedorBottomSheetState extends State<CreateVeedorBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  final _cedulaCtrl = TextEditingController();
  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

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
    
    final recintoId = context.read<RecintoCoordBloc>().state.recintoId;
    if (recintoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el recinto actual')),
      );
      return;
    }

    final coordinadorId = Supabase.instance.client.auth.currentUser?.id;
    if (coordinadorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo obtener el usuario actual')),
      );
      return;
    }

    context.read<RecintoCoordBloc>().add(
      CrearVeedorEvent(
        cedula: _cedulaCtrl.text.trim(),
        nombres: _nombresCtrl.text.trim(),
        apellidos: _apellidosCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        recintoId: recintoId,
        coordinadorId: coordinadorId,
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
              'Nuevo Veedor',
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
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Cédula',
                prefixIcon: Icon(Icons.badge_outlined),
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'La cédula es requerida';
                if (!CedulaValidator.validar(v)) return 'Cédula inválida';
                return null;
              },
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
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Crear Veedor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
