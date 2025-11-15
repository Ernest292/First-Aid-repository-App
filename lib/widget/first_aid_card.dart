// lib/widgets/first_aid_card.dart
import 'package:flutter/material.dart';
import '../models/first_aid.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class FirstAidCard extends StatelessWidget {
  final FirstAid item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const FirstAidCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final created = DateFormat.yMMMd().add_Hm().format(item.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: item.imagePath != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            File(item.imagePath!),
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        )
            : Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.medical_services, color: Colors.red),
        ),
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
}
