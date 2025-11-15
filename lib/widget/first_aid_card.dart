import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/first_aid.dart';

class FirstAidCard extends StatelessWidget {
  final FirstAid item;
  final VoidCallback onTap, onDelete, onEdit;

  const FirstAidCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  bool get _hasImage => item.imagePath != null && item.imagePath!.isNotEmpty;

  get DateFormat => null;

  @override
  Widget build(BuildContext context) {
    final created = DateFormat.yMMMd().add_Hm().format(item.createdAt);

    // Initialize leadingWidget with placeholder
    Widget leadingWidget = _placeholder();

    if (_hasImage) {
      if (kIsWeb || item.imagePath!.startsWith('http')) {
        leadingWidget = Image.network(
          item.imagePath!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (c, e, st) => _placeholder(),
        );
      } else {
        final file = File(item.imagePath!);
        if (file.existsSync()) {
          leadingWidget = Image.file(
            file,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          );
        }
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: leadingWidget,
        title: Text(item.title),
        subtitle: Text(
          '${item.description}\nCreated: $created',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(6),
    ),
    child: const Icon(Icons.medical_services, color: Colors.red),
  );
}
