import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/veedor_entity.dart';
import '../bloc/recinto_coord_bloc.dart';
import '../bloc/recinto_coord_event.dart';
import '../bloc/recinto_coord_state.dart';
import '../widgets/create_veedor_bottom_sheet.dart';

class MisVeedoresPage extends StatefulWidget {
  const MisVeedoresPage({super.key});

  @override
  State<MisVeedoresPage> createState() => _MisVeedoresPageState();
}

class _MisVeedoresPageState extends State<MisVeedoresPage> {
  String _searchQuery = '';
  List<VeedorEntity>? _localVeedores;

  void _showCrearVeedorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<RecintoCoordBloc>(),
        child: const CreateVeedorBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecintoCoordBloc>();

    return BlocListener<RecintoCoordBloc, RecintoCoordState>(
      listenWhen: (previous, current) {
        if (previous.veedores != current.veedores) {
          _localVeedores = List.from(current.veedores);
        }
        return (previous.successMessage != current.successMessage && current.successMessage != null) ||
            (previous.errorMessage != current.errorMessage && current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              state.successMessage!,
              style: const TextStyle(color: AppTheme.flagBlue, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.flagYellow,
          ));
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.flagBlue,
          onPressed: () => _showCrearVeedorSheet(context),
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
        body: BlocBuilder<RecintoCoordBloc, RecintoCoordState>(
          builder: (context, state) {
            if (state.isLoading && state.veedores.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_localVeedores == null) {
              _localVeedores = List.from(state.veedores);
            }
            final veedores = _localVeedores!;

            if (veedores.isEmpty && _searchQuery.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No hay veedores registrados.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              );
            }

            final filtered = veedores.where((v) {
              final q = _searchQuery.toLowerCase();
              return v.nombreCompleto.toLowerCase().contains(q) ||
                  (v.cedula ?? '').contains(q);
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar veedor por nombre o cédula...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final veedor = filtered[index];

                      return Dismissible(
                        key: ValueKey(veedor.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.flagRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar Veedor'),
                              content: Text('¿Seguro que deseas eliminar a ${veedor.nombreCompleto}? Esta acción no se puede deshacer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.flagRed, foregroundColor: Colors.white),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          setState(() {
                            _localVeedores?.removeWhere((v) => v.id == veedor.id);
                          });
                          bloc.add(EliminarVeedorEvent(veedorId: veedor.id));
                        },
                        child: Card(
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFEEF2FF),
                              child: Text(
                                veedor.nombres?.isNotEmpty == true ? veedor.nombres![0].toUpperCase() : 'V',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.flagBlue),
                              ),
                            ),
                            title: Text(
                              veedor.nombreCompleto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(veedor.cedula ?? 'Sin cédula', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  veedor.mesaAsignada ?? 'Sin mesa asignada',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: veedor.mesaAsignada != null ? AppTheme.flagBlue : Colors.black54,
                                    fontWeight: veedor.mesaAsignada != null ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
