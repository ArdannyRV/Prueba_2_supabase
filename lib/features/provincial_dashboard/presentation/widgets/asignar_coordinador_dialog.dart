import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';

class AsignarCoordinadorDialog extends StatefulWidget {
  final String recintoId;

  const AsignarCoordinadorDialog({super.key, required this.recintoId});

  @override
  State<AsignarCoordinadorDialog> createState() => _AsignarCoordinadorDialogState();
}

class _AsignarCoordinadorDialogState extends State<AsignarCoordinadorDialog> {
  String? _selectedCoordinadorId;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const FetchAllCoordinadoresEvent());
    context.read<ProvincialBloc>().add(const FetchUnassignedCoordinadoresEvent());
  }

  void _asignar() {
    if (_selectedCoordinadorId != null) {
      context.read<ProvincialBloc>().add(
        AsignarCoordinadorEvent(
          recintoId: widget.recintoId,
          coordinadorId: _selectedCoordinadorId!,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Asignar Coordinador',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 16),
            // Búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cédula...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
            const SizedBox(height: 16),
            // Lista
            Flexible(
              child: BlocBuilder<ProvincialBloc, ProvincialState>(
                builder: (context, state) {
                  if (state.isLoading && state.coordinadores.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final allCoordinadores = state.coordinadores;
                  final filtered = allCoordinadores.where((c) {
                    final query = _searchQuery.toLowerCase();
                    final nombre = c.nombreCompleto.toLowerCase();
                    final cedula = (c.cedula ?? '').toLowerCase();
                    return nombre.contains(query) || cedula.contains(query);
                  }).toList();
                  
                  if (filtered.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'No se encontraron coordinadores',
                          style: TextStyle(
                            color: Colors.grey, 
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }

                  final totalPages = (filtered.length / _itemsPerPage).ceil();
                  int effectivePage = _currentPage;
                  if (effectivePage > totalPages) {
                    effectivePage = totalPages;
                  }
                  
                  final startIndex = (effectivePage - 1) * _itemsPerPage;
                  final endIndex = (startIndex + _itemsPerPage > filtered.length) 
                      ? filtered.length 
                      : startIndex + _itemsPerPage;
                  
                  final paginated = filtered.sublist(startIndex, endIndex);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: paginated.length,
                          itemBuilder: (context, index) {
                            final c = paginated[index];
                            final isDisponible = state.unassignedCoordinadores.any((u) => u.id == c.id);
                            final isSelected = _selectedCoordinadorId == c.id;

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCoordinadorId = c.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.nombreCompleto,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isDisponible ? 'Disponible' : 'Ya asignado',
                                        style: TextStyle(
                                          color: isDisponible ? Colors.green.shade700 : Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (c.cedula != null && c.cedula!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'C.I: ${c.cedula}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Paginación
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: effectivePage > 1 
                              ? () => setState(() => _currentPage = effectivePage - 1) 
                              : null,
                          ),
                          Text(
                            'Página $effectivePage de $totalPages',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: effectivePage < totalPages 
                              ? () => setState(() => _currentPage = effectivePage + 1) 
                              : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedCoordinadorId == null ? null : _asignar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Asignar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
