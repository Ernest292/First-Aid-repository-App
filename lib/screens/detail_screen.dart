import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/first_aid.dart';

class DetailScreen extends StatelessWidget {
  final FirstAid item;
  const DetailScreen({Key? key, required this.item}) : super(key: key);

  bool get _hasImage => item.imagePath != null && item.imagePath!.isNotEmpty;

  get DateFormat => null;

  @override
  Widget build(BuildContext context) {
    final created = DateFormat.yMMMMd().add_jm().format(item.createdAt);
    final updated = DateFormat.yMMMMd().add_jm().format(item.updatedAt);

    Widget? imageWidget;
    if (_hasImage) {
      if (kIsWeb || item.imagePath!.startsWith('http')) {
        imageWidget = Image.network(item.imagePath!, width: double.infinity, height: 200, fit: BoxFit.cover,
            errorBuilder: (c, e, st) => _placeholder());
      } else {
        final file = File(item.imagePath!);
        if (file.existsSync()) imageWidget = Image.file(file, width: double.infinity, height: 200, fit: BoxFit.cover);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageWidget != null)
              Padding(padding: const EdgeInsets.only(bottom: 12.0), child: imageWidget),
            Text(item.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Text('Created: $created', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Last updated: $updated', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: double.infinity,
    height: 200,
    color: Colors.grey[300],
    child: const Icon(Icons.medical_services, color: Colors.red, size: 48),
  );
}
