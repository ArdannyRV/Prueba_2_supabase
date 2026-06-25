import 'package:flutter/material.dart';

class ChangeInitialPasswordPage extends StatelessWidget {
  const ChangeInitialPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar Contraseña')),
      body: const Center(child: Text('Pantalla de Cambio de Contraseña Inicial')),
    );
  }
}
