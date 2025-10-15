import 'package:flutter/material.dart';

class TileFormCard extends StatefulWidget {
  const TileFormCard({
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
  State<TileFormCard> createState() => _TileFormCardState();
}

class _TileFormCardState extends State<TileFormCard> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _notifyUpdate() {
    widget.onUpdate({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'imageUrl': _imageUrlController.text,
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Pet a dog',
                prefixIcon: Icon(Icons.title_rounded),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _notifyUpdate(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe this tile',
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
