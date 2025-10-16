import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/utils/debouncer.dart';

class ChallengeFormCard extends StatefulWidget {
  const ChallengeFormCard({
    required this.index,
    required this.data,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final int index;
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onUpdate;
  final VoidCallback onRemove;

  @override
  State<ChallengeFormCard> createState() => _ChallengeFormCardState();
}

class _ChallengeFormCardState extends State<ChallengeFormCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _unlockAmountController;
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.data['title'] as String? ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.data['description'] as String? ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.data['imageUrl'] as String? ?? '',
    );
    _unlockAmountController = TextEditingController(
      text: (widget.data['unlockAmount'] as int? ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _unlockAmountController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _notifyUpdate() {
    _debouncer.run(() {
      widget.onUpdate({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': _imageUrlController.text,
        'unlockAmount': int.tryParse(_unlockAmountController.text) ?? 1,
      });
    });
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
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Challenge ${widget.index + 1}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Remove challenge',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g., Complete a speedrun',
                      prefixIcon: Icon(Icons.title_rounded),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _notifyUpdate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _unlockAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Unlocks *',
                      hintText: '1',
                      prefixIcon: Icon(Icons.lock_open_rounded),
                      helperText: 'Tile count',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _notifyUpdate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what needs to be done',
                prefixIcon: Icon(Icons.description_rounded),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => _notifyUpdate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL *',
                hintText: 'https://example.com/image.png',
                prefixIcon: Icon(Icons.image_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _notifyUpdate(),
            ),
          ],
        ),
      ),
    );
  }
}
