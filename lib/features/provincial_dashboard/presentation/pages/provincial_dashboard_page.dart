import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProvincialDashboardPage extends StatefulWidget {
  const ProvincialDashboardPage({super.key});

  @override
  State<ProvincialDashboardPage> createState() => _ProvincialDashboardPageState();
}

class _ProvincialDashboardPageState extends State<ProvincialDashboardPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _recintosFuture;

  @override
  void initState() {
    super.initState();
    _fetchRecintos();
  }

  void _fetchRecintos() {
    setState(() {
      _recintosFuture = supabase.from('recintos').select('*');
    });
  }

  void _logout() async {
    await supabase.auth.signOut();
    // Navegar de vuelta al login o la pantalla inicial (ajusta la ruta según tu app)
    if (mounted) {
      // Reemplaza '/' con la ruta de tu pantalla de login si es diferente
      Navigator.of(context).pushReplacementNamed('/'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8), // Fondo moderno y claro
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo.shade700,
        title: Text(
          'Panel Provincial',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recintosFuture,
        builder: (context, snapshot) {
          // 1. Estado: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Estado: Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      '¡Uy! Hubo un problema al cargar los recintos.',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Por favor, revisa tu conexión e inténtalo de nuevo.\nDetalles: ${snapshot.error}',
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _fetchRecintos,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            );
          }

          // 3. Estado: Éxito (Con datos o Vacío)
          final recintos = snapshot.data;

          if (recintos == null || recintos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay recintos registrados aún.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchRecintos();
              await _recintosFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: recintos.length,
              itemBuilder: (context, index) {
                final recinto = recintos[index];
                final nombre = recinto['nombre'] ?? 'Sin nombre';
                final parroquia = recinto['parroquia'] ?? 'Sin parroquia';
                final canton = recinto['canton'] ?? 'Sin cantón';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Icon(Icons.how_to_vote_rounded, color: Colors.indigo.shade700),
                    ),
                    title: Text(
                      nombre,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.top(8.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$parroquia, $canton',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      // Acción al presionar la tarjeta (ej. ver detalles del recinto)
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          debugPrint('NUEVO COORDINADOR DE RECINTO: Acción disparada');
        },
        backgroundColor: Colors.indigo.shade600,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'Nuevo Coordinador de Recinto',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
