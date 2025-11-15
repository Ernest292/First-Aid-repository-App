// lib/db/database_helper.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/first_aid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const String tableFirstAid = 'first_aid';
  static const String storageBucket = 'first-aid-images';

  /// Uploads a File to Supabase Storage and returns public URL
  Future<String?> uploadImage(File file, String filePath) async {
    try {
      // Upload the file to Supabase storage
      await _supabase.storage.from(storageBucket).upload(filePath, file);

      // Get public URL
      final url = _supabase.storage.from(storageBucket).getPublicUrl(filePath);

      return url; // already a String
    } catch (e) {
      print('Supabase upload error: $e');
      return null;
    }
  }

  /// CREATE
  Future<FirstAid> createFirstAid(FirstAid item) async {
    final now = DateTime.now().toIso8601String();

    final response = await _supabase
        .from(tableFirstAid)
        .insert({
      'title': item.title,
      'description': item.description,
      'instructions': item.instructions,
      'image_path': item.imagePath,
      'created_at': now,
      'updated_at': now,
    })
        .select()
        .single();

    return FirstAid.fromMap(response);
  }

  /// READ ALL
  Future<List<FirstAid>> readAllFirstAids() async {
    final res = await _supabase
        .from(tableFirstAid)
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => FirstAid.fromMap(e)).toList();
  }

  /// READ ONE BY ID
  Future<FirstAid?> readFirstAid(int id) async {
    final res = await _supabase
        .from(tableFirstAid)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (res == null) return null;
    return FirstAid.fromMap(res);
  }

  /// UPDATE
  Future<int> updateFirstAid(FirstAid item) async {
    item.updatedAt = DateTime.now();

    try {
      await _supabase.from(tableFirstAid).update({
        'title': item.title,
        'description': item.description,
        'instructions': item.instructions,
        'image_path': item.imagePath,
        'updated_at': item.updatedAt.toIso8601String(),
      }).eq('id', item.id);

      return 1;
    } catch (e) {
      print('Supabase update error: $e');
      return 0;
    }
  }

  /// DELETE
  Future<int> deleteFirstAid(int id) async {
    try {
      await _supabase.from(tableFirstAid).delete().eq('id', id);
      return 1;
    } catch (e) {
      print('Supabase delete error: $e');
      return 0;
    }
  }
}
