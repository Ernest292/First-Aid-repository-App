// lib/models/first_aid.dart
import 'package:flutter/foundation.dart';

class FirstAid {
  int? id;
  String title;
  String description;
  String instructions;
  String? imagePath; // local file path to an image (optional)
  DateTime createdAt;
  DateTime updatedAt;

  FirstAid({
    this.id,
    required this.title,
    required this.description,
    required this.instructions,
    this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory FirstAid.fromMap(Map<String, dynamic> map) {
    return FirstAid(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      instructions: map['instructions'] as String,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'instructions': instructions,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
