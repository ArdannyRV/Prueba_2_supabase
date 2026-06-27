import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../../../../core/theme/app_theme.dart';

class AsignarCoordinadorDialog extends StatefulWidget {
  final String recintoId;

  const AsignarCoordinadorDialog({super.key, required this.recintoId});

  @override
  State<AsignarCoordinadorDialog> createState() =>
      _AsignarCoordinadorDialogState();
}

class _AsignarCoordinadorDialogState extends State<AsignarCoordinadorDialog> {
  String? _selectedCoordinadorId;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 4; // 4 para que quepan con el botón

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: double.infinity,
        height: screenHeight * 0.72, // altura fija — Flutter puede resolver Expanded
        child: Column(
          mainAxisSize: MainAxisSize.max, // max para que ocupe exactamente el SizedBox
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── franja degradada ──────────────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.flagYellow, AppTheme.flagRed],
                ),
              ),
            ),

            // ── título ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'Asignar Coordinador',
                style: TextStyle(
                  color: AppTheme.flagBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── buscador ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o cédula...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() {
                  _searchQuery = v;
                  _currentPage = 1;
                }),
              ),
            ),
            const SizedBox(height: 10),

            // ── lista (Expanded toma todo el espacio restante) ────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<ProvincialBloc, ProvincialState>(
                  builder: (context, state) {
                    if (state.isLoading && state.coordinadores.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filtered = state.coordinadores.where((c) {
                      final q = _searchQuery.toLowerCase();
                      return c.nombreCompleto.toLowerCase().contains(q) ||
                          (c.cedula ?? '').toLowerCase().contains(q);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron coordinadores',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      );
                    }

                    final totalPages =
                        (filtered.length / _itemsPerPage).ceil();
                    final effectivePage =
                        _currentPage.clamp(1, totalPages);
                    final startIndex = (effectivePage - 1) * _itemsPerPage;
                    final endIndex =
                        (startIndex + _itemsPerPage).clamp(0, filtered.length);
                    final paginated = filtered.sublist(startIndex, endIndex);

                    return Column(
                      children: [
                        // lista ocupa el espacio disponible
                        Expanded(
                          child: ListView.builder(
                            itemCount: paginated.length,
                            itemBuilder: (context, index) {
                              final c = paginated[index];
                              final isDisponible = state
                                  .unassignedCoordinadores
                                  .any((u) => u.id == c.id);
                              final isSelected =
                                  _selectedCoordinadorId == c.id;

                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.flagBlue
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => setState(
                                      () => _selectedCoordinadorId = c.id),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.nombreCompleto,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isDisponible
                                              ? 'Disponible'
                                              : 'Ya asignado',
                                          style: TextStyle(
                                            color: isDisponible
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (c.cedula != null &&
                                            c.cedula!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'C.I: ${c.cedula}',
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // paginación — tamaño fijo, siempre visible
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              iconSize: 20,
                              icon: const Icon(Icons.chevron_left),
                              onPressed: effectivePage > 1
                                  ? () => setState(
                                      () => _currentPage = effectivePage - 1)
                                  : null,
                            ),
                            Text(
                              'Página $effectivePage de $totalPages',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            IconButton(
                              iconSize: 20,
                              icon: const Icon(Icons.chevron_right),
                              onPressed: effectivePage < totalPages
                                  ? () => setState(
                                      () => _currentPage = effectivePage + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ── botones — SIEMPRE al fondo, fuera del Expanded ───────
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10)),
                    child: Text('Cancelar',
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        _selectedCoordinadorId == null ? null : _asignar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.flagBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Asignar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}