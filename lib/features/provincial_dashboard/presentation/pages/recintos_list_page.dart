import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/provincial_bloc.dart';
import '../bloc/provincial_event.dart';
import '../bloc/provincial_state.dart';
import '../widgets/create_recinto_bottom_sheet.dart';
import '../../domain/entities/recinto_entity.dart';
import 'recinto_detail_page.dart';

class RecintosListPage extends StatefulWidget {
  const RecintosListPage({super.key});

  @override
  State<RecintosListPage> createState() => _RecintosListPageState();
}

class _RecintosListPageState extends State<RecintosListPage> {
  List<RecintoEntity>? _localRecintos;
  String _searchQuery = '';
  String? _parroquiaFiltro;
  int _currentPage = 1;
  final int _itemsPerPage = 4;
  
  static const List<String> _parroquiasQuito = [
    'Belisario Quevedo','Calderón','Carcelén','Centro Histórico',
    'Chillogallo','Chimbacalle','Cochapamba','Cotocollao','El Condado',
    'Guamaní','Iñaquito','Jipijapa','Kennedy','La Concepción',
    'La Ecuatoriana','La Ferroviaria','La Libertad','La Magdalena',
    'Las Casas','Llano Chico','Mariscal Sucre','Nayón','Ponceano',
    'Puengasí','Quitumbe','Solanda','Tumbaco','Turubamba',
  ];
  
  void _showCreateRecintoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProvincialBloc>(),
        child: const CreateRecintoBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProvincialBloc>();

    return BlocListener<ProvincialBloc, ProvincialState>(
      listenWhen: (previous, current) {
        if (previous.recintos != current.recintos) {
          _localRecintos = List.from(current.recintos);
        }
        return (previous.successMessage != current.successMessage && current.successMessage != null) ||
               (previous.errorMessage != current.errorMessage && current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
          ));
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: BlocBuilder<ProvincialBloc, ProvincialState>(
          builder: (context, state) {
            if (state.isLoading && state.recintos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_localRecintos == null) {
              _localRecintos = List.from(state.recintos);
            }
            final recintos = _localRecintos!;

            final filtered = recintos.where((r) {
              final q = _searchQuery.toLowerCase();
              final matchSearch = r.nombre.toLowerCase().contains(q) ||
                  r.parroquia.toLowerCase().contains(q);
              final matchParroquia = _parroquiaFiltro == null ||
                  r.parroquia == _parroquiaFiltro;
              return matchSearch && matchParroquia;
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
                            hintText: 'Buscar recinto o parroquia...',
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
                          onPressed: () => _showCreateRecintoBottomSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Icon(Icons.add_business_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text('Todos', style: _parroquiaFiltro == null ? const TextStyle(color: AppTheme.flagBlue, fontSize: 11, fontWeight: FontWeight.w600) : const TextStyle(color: Colors.black, fontSize: 11)),
                        selectedColor: AppTheme.flagYellow,
                        checkmarkColor: AppTheme.flagBlue,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.flagBlue, width: 0.8),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        selected: _parroquiaFiltro == null,
                        onSelected: (_) => setState(() {
                          _parroquiaFiltro = null;
                          _currentPage = 1;
                        }),
                      ),
                      ..._parroquiasQuito.map((p) => FilterChip(
                            label: Text(p, style: _parroquiaFiltro == p ? const TextStyle(color: AppTheme.flagBlue, fontSize: 11, fontWeight: FontWeight.w600) : const TextStyle(color: Colors.black, fontSize: 11)),
                            selectedColor: AppTheme.flagYellow,
                            checkmarkColor: AppTheme.flagBlue,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppTheme.flagBlue, width: 0.8),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            selected: _parroquiaFiltro == p,
                            onSelected: (_) => setState(() {
                              _parroquiaFiltro = p;
                              _currentPage = 1;
                            }),
                          )),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No se encontraron recintos.',
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
                            onRefresh: () async {
                              bloc.add(const FetchRecintosEvent());
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              itemCount: paginated.length,
                              itemBuilder: (context, index) {
                                final recinto = paginated[index];

                  return Dismissible(
                    key: Key(recinto.id),
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
                          title: const Text('Eliminar recinto'),
                          content: Text('¿Estás seguro de eliminar "${recinto.nombre}"? Esta acción no se puede deshacer.'),
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
                        _localRecintos!.removeWhere((r) => r.id == recinto.id);
                      });
                      bloc.add(DeleteRecintoEvent(recintoId: recinto.id));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: (recinto.coordinadorNombre != null && recinto.coordinadorNombre!.isNotEmpty) ? AppTheme.flagBlue : AppTheme.flagRed, width: 3)),
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
                        minLeadingWidth: 32,
                        contentPadding: const EdgeInsets.only(left: 10, right: 6, top: 0, bottom: 0),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Icon(Icons.how_to_vote_rounded, size: 16, color: AppTheme.primaryColor),
                        ),
                        title: Text(
                          recinto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 13,
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
                                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${recinto.parroquia}, ${recinto.canton}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Builder(builder: (context) {
                                Color statusColor;
                                if (recinto.mesasConActa == 0) {
                                  statusColor = Colors.grey.shade600;
                                } else if (recinto.mesasConActa == recinto.totalMesas) {
                                  statusColor = const Color(0xFF1B7A3D);
                                } else {
                                  statusColor = const Color(0xFF00308F);
                                }
                                return Row(
                                  children: [
                                    Icon(Icons.pie_chart, size: 14, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recinto.mesasConActa} / ${recinto.totalMesas} mesas con acta',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 1),
                              Builder(builder: (context) {
                                final tieneCoordinador = recinto.coordinadorNombre != null &&
                                    recinto.coordinadorNombre!.isNotEmpty;
                                return Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: tieneCoordinador ? Colors.green.shade700 : Colors.red.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tieneCoordinador ? recinto.coordinadorNombre! : 'Sin coordinador',
                                        style: TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w600,
                                          color: tieneCoordinador ? Colors.green.shade700 : Colors.red.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: bloc,
                                child: RecintoDetailPage(recinto: recinto),
                              ),
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

