import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';

class CreateRecintoBottomSheet extends StatefulWidget {
  const CreateRecintoBottomSheet({super.key});

  @override
  State<CreateRecintoBottomSheet> createState() => _CreateRecintoBottomSheetState();
}

class _CreateRecintoBottomSheetState extends State<CreateRecintoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _parroquiaController = TextEditingController();
  final _cantonController = TextEditingController(text: 'Quito');
  final _mesasController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nombreController.dispose();
    _parroquiaController.dispose();
    _cantonController.dispose();
    _mesasController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProvincialBloc>().add(CreateRecintoEvent(
          nombre: _nombreController.text.trim(),
          parroquia: _parroquiaController.text.trim(),
          canton: _cantonController.text.trim(),
          totalMesas: int.parse(_mesasController.text.trim()),
        ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding para que el teclado no tape el formulario
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nuevo Recinto',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Recinto', prefixIcon: Icon(Icons.school)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _parroquiaController,
                decoration: const InputDecoration(labelText: 'Parroquia', prefixIcon: Icon(Icons.map)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cantonController,
                decoration: const InputDecoration(labelText: 'Cantón', prefixIcon: Icon(Icons.location_city)),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mesasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total de Mesas (JRV)', prefixIcon: Icon(Icons.how_to_vote)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final num = int.tryParse(v);
                  if (num == null || num <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text('Guardar Recinto', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
