import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_models/shared_models.dart';

class UniqueItemsSelectionDialog extends StatefulWidget {
  const UniqueItemsSelectionDialog({
    required this.boss,
    required this.initialItems,
    required this.initialIsAnyUnique,
    required this.initialIsOrLogic,
    required this.initialAnyNCount,
    super.key,
  });

  final Boss boss;
  final List<TileUniqueItem> initialItems;
  final bool initialIsAnyUnique;
  final bool initialIsOrLogic;
  final int? initialAnyNCount;

  @override
  State<UniqueItemsSelectionDialog> createState() =>
      _UniqueItemsSelectionDialogState();
}

class _UniqueItemsSelectionDialogState
    extends State<UniqueItemsSelectionDialog> {
  late final Map<String, int> _selectedItems;
  late bool _isAnyUnique;
  late bool _isOrLogic;
  late int? _anyNCount;
  final TextEditingController _anyNCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isAnyUnique = widget.initialIsAnyUnique;
    _isOrLogic = widget.initialIsOrLogic;
    _anyNCount = widget.initialAnyNCount;
    _selectedItems = {};
    for (final item in widget.initialItems) {
      _selectedItems[item.itemName] = item.requiredCount;
    }
    if (_anyNCount != null) {
      _anyNCountController.text = _anyNCount.toString();
    }
  }

  @override
  void dispose() {
    _anyNCountController.dispose();
    super.dispose();
  }

  void _onItemToggled(String itemName, bool selected) {
    setState(() {
      if (selected) {
        _selectedItems[itemName] = 1;
      } else {
        _selectedItems.remove(itemName);
      }
    });
  }

  void _onItemCountChanged(String itemName, int count) {
    if (count < 1) return;
    setState(() {
      _selectedItems[itemName] = count;
    });
  }

  void _onAnyUniqueChanged(bool value) {
    setState(() {
      _isAnyUnique = value;
      if (value) {
        _selectedItems.clear();
      }
    });
  }

  void _onOrLogicChanged(bool value) {
    setState(() {
      _isOrLogic = value;
      if (!value) {
        _anyNCount = null;
        _anyNCountController.clear();
      }
    });
  }

  void _onAnyNCountChanged(String value) {
    setState(() {
      _anyNCount = int.tryParse(value);
    });
  }

  bool _isValid() {
    if (_isAnyUnique) return true;
    return _selectedItems.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Text(
                    'Select Unique Items',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('Any Unique Item'),
                      subtitle: Text(
                        'Accept any unique item from ${widget.boss.name}\'s drop table',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: _isAnyUnique,
                      onChanged: (value) => _onAnyUniqueChanged(value ?? false),
                    ),
                    if (!_isAnyUnique) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Logic:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('AND'),
                            selected: !_isOrLogic,
                            onSelected: (selected) {
                              if (selected) _onOrLogicChanged(false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('OR'),
                            selected: _isOrLogic,
                            onSelected: (selected) {
                              if (selected) _onOrLogicChanged(true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isOrLogic
                            ? (_anyNCount != null && _anyNCount! > 1
                                  ? 'Obtain any $_anyNCount of the selected items'
                                  : 'Obtain any of the selected items')
                            : 'Obtain all of the selected items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_isOrLogic) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Any N Count:',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _anyNCountController,
                                decoration: const InputDecoration(
                                  hintText: 'Count',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: _onAnyNCountChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(leave empty for "any one")',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Select Items:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.boss.uniqueItems.map((itemName) {
                        final isSelected = _selectedItems.containsKey(itemName);
                        final count = _selectedItems[itemName] ?? 1;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            title: Text(itemName),
                            value: isSelected,
                            onChanged: (selected) {
                              _onItemToggled(itemName, selected ?? false);
                            },
                            secondary: isSelected
                                ? SizedBox(
                                    width: 80,
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Count',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        final count = int.tryParse(value) ?? 1;
                                        _onItemCountChanged(itemName, count);
                                      },
                                      controller:
                                          TextEditingController(
                                              text: count.toString(),
                                            )
                                            ..selection =
                                                TextSelection.collapsed(
                                                  offset: count
                                                      .toString()
                                                      .length,
                                                ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isValid()
                        ? () {
                            final items = _isAnyUnique
                                ? <TileUniqueItem>[]
                                : _selectedItems.entries
                                      .map(
                                        (e) => TileUniqueItem(
                                          itemName: e.key,
                                          requiredCount: e.value,
                                        ),
                                      )
                                      .toList();

                            Navigator.of(context).pop({
                              'items': items,
                              'isAnyUnique': _isAnyUnique,
                              'isOrLogic': _isOrLogic,
                              'anyNCount': _anyNCount,
                            });
                          }
                        : null,
                    child: const Text('Save'),
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
