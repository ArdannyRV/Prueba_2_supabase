import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../../../../core/utils/nombre_validator.dart';
import '../../../../core/utils/telefono_validator.dart';

class CreateCoordinadorForm extends StatefulWidget {
  const CreateCoordinadorForm({super.key});

  @override
  State<CreateCoordinadorForm> createState() => _CreateCoordinadorFormState();
}

class _CreateCoordinadorFormState extends State<CreateCoordinadorForm> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  bool _validarCedula(String cedula) {
    if (cedula.length != 10) return false;
    final int provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    int suma = 0;
    for (int i = 0; i < 9; i++) {
      int valor = int.parse(cedula[i]);
      if (i % 2 == 0) {
        valor = valor * 2;
        if (valor > 9) valor = valor - 9;
      }
      suma += valor;
    }

    int digitoVerificador = 10 - (suma % 10);
    if (digitoVerificador == 10) digitoVerificador = 0;

    return digitoVerificador == int.parse(cedula[9]);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<ProvincialBloc>().add(
        CreateCoordinadorIndependienteEvent(
          cedula: _cedulaController.text.trim(),
          nombres: _nombresController.text.trim(),
          apellidos: _apellidosController.text.trim(),
          telefono: _telefonoController.text.trim(),
          correo: _correoController.text.trim(),
        ),
      );
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nuevo Coordinador',
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
                controller: _cedulaController,
                decoration: const InputDecoration(
                  labelText: 'Cédula (10 dígitos)',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  if (!_validarCedula(val)) return 'Cédula inválida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombresController,
                      decoration: const InputDecoration(labelText: 'Nombres'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        if (!NombreValidator.validar(val)) return 'Solo se permiten letras';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _apellidosController,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Requerido';
                        if (!NombreValidator.validar(val)) return 'Solo se permiten letras';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                  counterText: '',
                ),
                keyboardType: TextInputType.phone,
                maxLength: TelefonoValidator.longitudExacta,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  if (!TelefonoValidator.validar(val)) {
                    return 'Debe tener exactamente ${TelefonoValidator.longitudExacta} dígitos numéricos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Requerido';
                  if (!val.contains('@')) return 'Correo inválido';
                  return null;
                },
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
                  child: const Text('Crear Coordinador', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
