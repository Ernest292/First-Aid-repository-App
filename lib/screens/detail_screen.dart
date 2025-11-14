// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import '../models/first_aid.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class DetailScreen extends StatelessWidget {
  final FirstAid item;
  const DetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final created = DateFormat.yMMMMd().add_jm().format(item.createdAt);
    final updated = DateFormat.yMMMMd().add_jm().format(item.updatedAt);
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Image.file(File(item.imagePath!)),
              ),
            Text(item.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(item.instructions, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Created: $created'),
            Text('Last updated: $updated'),
          ],
        ),
      ),
    );
  }
}
