import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_coordinador_form.dart';
import '../widgets/update_coordinador_form.dart';
import '../../domain/entities/coordinador_entity.dart';

class CoordinadoresListPage extends StatefulWidget {
  const CoordinadoresListPage({super.key});

  @override
  State<CoordinadoresListPage> createState() => _CoordinadoresListPageState();
}

class _CoordinadoresListPageState extends State<CoordinadoresListPage> {
  List<CoordinadorEntity>? _localCoordinadores;
  String _searchQuery = '';
  String _filtroAsignacion = 'todos';
  int _currentPage = 1;
  final int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    context.read<ProvincialBloc>().add(const FetchAllCoordinadoresEvent());
  }

  void _showCreateCoordinadorForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: const CreateCoordinadorForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProvincialBloc>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: BlocListener<ProvincialBloc, ProvincialState>(
        listenWhen: (previous, current) {
          if (previous.coordinadores != current.coordinadores) {
            _localCoordinadores = List.from(current.coordinadores);
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
        child: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state.isLoading && state.coordinadores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_localCoordinadores == null) {
            _localCoordinadores = List.from(state.coordinadores);
          }
          final coordinadores = _localCoordinadores!;

          if (coordinadores.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No hay coordinadores registrados.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              );
            }

            final filtered = coordinadores.where((c) {
              final q = _searchQuery.toLowerCase();
              final matchSearch = c.nombreCompleto.toLowerCase().contains(q) ||
                  (c.cedula ?? '').contains(q);
              final estaAsignado = c.recintoAsignado != null;
              final matchFiltro = _filtroAsignacion == 'todos' ||
                  (_filtroAsignacion == 'asignados' && estaAsignado) ||
                  (_filtroAsignacion == 'sin_asignar' && !estaAsignado);
              return matchSearch && matchFiltro;
            }).toList();

            final totalPages = (filtered.length / _itemsPerPage).ceil().clamp(1, 9999);
            final effectivePage = _currentPage.clamp(1, totalPages);
            final startIndex = (effectivePage - 1) * _itemsPerPage;
            final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
            final paginated = filtered.sublist(startIndex, endIndex);

            return Column(
              children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o cédula...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (v) => setState(() {
                            _searchQuery = v;
                            _currentPage = 1;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: ElevatedButton(
                          onPressed: _showCreateCoordinadorForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Icon(Icons.person_add_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      for (final opcion in [
                        ('todos', 'Todos'),
                        ('asignados', 'Asignados'),
                        ('sin_asignar', 'Sin asignar'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(opcion.$2, style: TextStyle(
                              color: _filtroAsignacion == opcion.$1 ? AppTheme.flagBlue : Colors.black,
                              fontSize: 11,
                              fontWeight: _filtroAsignacion == opcion.$1 ? FontWeight.w600 : FontWeight.normal,
                            )),
                            selected: _filtroAsignacion == opcion.$1,
                            onSelected: (_) => setState(() {
                              _filtroAsignacion = opcion.$1;
                              _currentPage = 1;
                            }),
                            selectedColor: AppTheme.flagYellow,
                            checkmarkColor: AppTheme.flagBlue,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppTheme.flagBlue, width: 0.8),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No se encontraron coordinadores.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => bloc.add(const FetchAllCoordinadoresEvent()),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              itemCount: paginated.length,
                              itemBuilder: (context, index) {
                                final coordinador = paginated[index];

                  return Dismissible(
                    key: Key(coordinador.id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar coordinador'),
                          content: Text('¿Estás seguro de eliminar a "${coordinador.nombreCompleto}"?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Eliminar', style: TextStyle(color: Colors.red.shade700)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) {
                      setState(() {
                        _localCoordinadores?.removeWhere((c) => c.id == coordinador.id);
                      });
                      bloc.add(DeleteCoordinadorEvent(coordinadorId: coordinador.id));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: (coordinador.recintoAsignado != null) ? AppTheme.flagBlue : AppTheme.flagRed, width: 3)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Card(
                      margin: EdgeInsets.zero,
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
                        ),
                        title: Text(
                          coordinador.nombreCompleto,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.badge, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    coordinador.cedula ?? 'Sin cédula',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Row(
                                children: [
                                  Icon(Icons.home_work_outlined, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    coordinador.recintoAsignado ?? 'Sin asignar',
                                    style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.edit, color: Colors.grey, size: 20),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                            builder: (_) => BlocProvider.value(
                              value: context.read<ProvincialBloc>(),
                              child: UpdateCoordinadorForm(coordinador: coordinador),
                            ),
                          );
                        },
                      ),
                    ),
                    ),
                  );
                        },
                      ),
                    ),
                  ),
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_left),
                            onPressed: effectivePage > 1
                                ? () => setState(() => _currentPage = effectivePage - 1)
                                : null,
                          ),
                          Text(
                            'Página $effectivePage de $totalPages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.chevron_right),
                            onPressed: effectivePage < totalPages
                                ? () => setState(() => _currentPage = effectivePage + 1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
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
