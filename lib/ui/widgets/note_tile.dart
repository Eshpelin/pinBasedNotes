import 'package:flutter/material.dart';
import '../../data/models/note.dart';
import '../../utils/date_format.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Note'),
            content: Text('Delete "${note.title}"?\n\nThis action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          note.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show preview of note content
            if (note.plainText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  note.preview,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Last edited timestamp
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Last edited ${DateFormatter.formatTimestamp(note.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Note'),
                content: Text('Delete "${note.title}"?\n\nThis action cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              onDelete();
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
