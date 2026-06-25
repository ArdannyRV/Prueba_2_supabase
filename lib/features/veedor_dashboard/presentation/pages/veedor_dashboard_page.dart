import 'package:flutter/material.dart';

class VeedorDashboardPage extends StatelessWidget {
  const VeedorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Veedor')),
      body: const Center(child: Text('Dashboard de Veedor')),
    );
  }
}
