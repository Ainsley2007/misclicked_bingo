import 'package:flutter/material.dart';
import 'package:frontend/core/utils/debouncer.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/presentation/widgets/unique_items_selection_dialog.dart';
import 'package:shared_models/shared_models.dart';

class TileFormCard extends StatefulWidget {
  const TileFormCard({
    required this.index,
    required this.data,
    required this.bosses,
    required this.onUpdate,
    required this.onRemove,
    this.isPointsMode = false,
    super.key,
  });

  final int index;
  final GameTileCreation data;
  final List<Boss> bosses;
  final Function(GameTileCreation) onUpdate;
  final VoidCallback onRemove;
  final bool isPointsMode;

  @override
  State<TileFormCard> createState() => _TileFormCardState();
}

class _TileFormCardState extends State<TileFormCard> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  final _debouncer = Debouncer(milliseconds: 500);
  Boss? _selectedBoss;
  final Map<String, int> _selectedItems = {}; // itemName -> requiredCount
  bool _isAnyUnique = false;
  bool _isOrLogic = false;
  int? _anyNCount;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.data.description ?? '',
    );
    _pointsController = TextEditingController(
      text: widget.data.points > 0 ? widget.data.points.toString() : '',
    );
    _isAnyUnique = widget.data.isAnyUnique;
    _isOrLogic = widget.data.isOrLogic;
    _anyNCount = widget.data.anyNCount;
    _showDescription = widget.data.description?.isNotEmpty ?? false;
    _loadInitialData();
  }

  @override
  void didUpdateWidget(TileFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bosses != widget.bosses ||
        oldWidget.data.bossId != widget.data.bossId) {
      _loadInitialData();
    }
  }

  void _loadInitialData() {
    final bossId = widget.data.bossId;
    if (bossId != null && widget.bosses.isNotEmpty) {
      final boss = widget.bosses.firstWhere(
        (b) => b.id == bossId,
        orElse: () => widget.bosses.first,
      );
      setState(() {
        _selectedBoss = boss;
      });
      _loadSelectedItems();
    }

    final description = widget.data.description;
    if (description != null) {
      _descriptionController.text = description;
    }
  }

  void _loadSelectedItems() {
    final uniqueItems = widget.data.uniqueItems;
    setState(() {
      _isAnyUnique = widget.data.isAnyUnique;
      _isOrLogic = widget.data.isOrLogic;
      _anyNCount = widget.data.anyNCount;
      _selectedItems.clear();
      for (final item in uniqueItems) {
        _selectedItems[item.itemName] = item.requiredCount;
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pointsController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _notifyUpdate() {
    _debouncer.run(() {
      if (_selectedBoss == null) {
        return;
      }

      final points = int.tryParse(_pointsController.text) ?? 0;

      widget.onUpdate(
        GameTileCreation(
          bossId: _selectedBoss!.id,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          uniqueItems: _isAnyUnique
              ? []
              : _selectedItems.entries
                    .map(
                      (e) => TileUniqueItem(
                        itemName: e.key,
                        requiredCount: e.value,
                      ),
                    )
                    .toList(),
          isAnyUnique: _isAnyUnique,
          isOrLogic: _isOrLogic,
          anyNCount: _anyNCount,
          points: points,
        ),
      );
    });
  }

  void _onBossSelected(Boss? boss) {
    setState(() {
      _selectedBoss = boss;
      _selectedItems.clear();
      _isAnyUnique = false;
      _isOrLogic = false;
      _anyNCount = null;
    });
    _notifyUpdate();
  }

  Future<void> _openUniqueItemsDialog() async {
    if (_selectedBoss == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => UniqueItemsSelectionDialog(
        boss: _selectedBoss!,
        initialItems: widget.data.uniqueItems,
        initialIsAnyUnique: _isAnyUnique,
        initialIsOrLogic: _isOrLogic,
        initialAnyNCount: _anyNCount,
      ),
    );

    if (result != null) {
      setState(() {
        _isAnyUnique = result['isAnyUnique'] as bool;
        _isOrLogic = result['isOrLogic'] as bool;
        _anyNCount = result['anyNCount'] as int?;
        final items = result['items'] as List<TileUniqueItem>;
        _selectedItems.clear();
        for (final item in items) {
          _selectedItems[item.itemName] = item.requiredCount;
        }
      });
      _notifyUpdate();
    }
  }

  String _getUniqueItemsSummary() {
    if (_isAnyUnique) {
      return 'Any unique item from ${_selectedBoss!.name}';
    }
    if (_selectedItems.isEmpty) {
      return 'No items selected';
    }
    final items = _selectedItems.entries
        .map((e) => e.value > 1 ? '${e.key} (x${e.value})' : e.key)
        .join(_isOrLogic ? ' OR ' : ' AND ');
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tile ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Remove tile',
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Boss>(
              value: _selectedBoss,
              decoration: InputDecoration(
                labelText: 'Boss *',
                prefixIcon:
                    _selectedBoss != null && _selectedBoss!.iconUrl.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.network(
                          _selectedBoss!.iconUrl,
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person_rounded, size: 24);
                          },
                        ),
                      )
                    : const Icon(Icons.person_rounded),
                border: const OutlineInputBorder(),
              ),
              selectedItemBuilder: (context) {
                return widget.bosses.map((boss) {
                  return Text(boss.name);
                }).toList();
              },
              items: widget.bosses.map((boss) {
                return DropdownMenuItem<Boss>(
                  value: boss,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (boss.iconUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.network(
                              boss.iconUrl,
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 24);
                              },
                            ),
                          ),
                        Flexible(child: Text(boss.name)),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: _onBossSelected,
            ),
            if (_selectedBoss != null) ...[
              const SizedBox(height: 16),
              Text(
                'Unique Items *',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openUniqueItemsDialog,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Select Unique Items'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              if (_isAnyUnique || _selectedItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getUniqueItemsSummary(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (widget.isPointsMode) ...[
              const SizedBox(height: 16),
              BingoTextField(
                controller: _pointsController,
                decoration: InputDecoration(
                  labelText: 'Points *',
                  prefixIcon: const Icon(Icons.emoji_events_rounded),
                  border: const OutlineInputBorder(),
                  errorText:
                      _pointsController.text.isNotEmpty &&
                          (int.tryParse(_pointsController.text) ?? 0) <= 0
                      ? 'Points must be greater than 0'
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {});
                  _notifyUpdate();
                },
              ),
            ],
            const SizedBox(height: 16),
            if (_showDescription)
              BingoTextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  prefixIcon: const Icon(Icons.description_rounded),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _descriptionController.clear();
                        _showDescription = false;
                      });
                      _notifyUpdate();
                    },
                    tooltip: 'Remove description',
                  ),
                ),
                maxLines: 2,
                onChanged: (_) => _notifyUpdate(),
                autofocus: true,
              )
            else
              TextButton.icon(
                onPressed: () => setState(() => _showDescription = true),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add description'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
