import 'package:flutter/material.dart';

class RecintoDashboardPage extends StatelessWidget {
  const RecintoDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Recinto')),
      body: const Center(child: Text('Dashboard de Coordinador de Recinto')),
    );
  }
}
