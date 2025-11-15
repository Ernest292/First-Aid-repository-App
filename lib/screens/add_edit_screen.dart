import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/first_aid.dart';
import '../db/database_helper.dart';

class AddEditScreen extends StatefulWidget {
  final FirstAid? existing;
  const AddEditScreen({super.key, this.existing});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;
  String? _imagePath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existing?.description ?? '');
    _instructionsController = TextEditingController(text: widget.existing?.instructions ?? '');
    _imagePath = widget.existing?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) return; // image picking disabled on web

    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;
    setState(() => _imagePath = xfile.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final helper = DatabaseHelper.instance;
    String? finalImagePath = _imagePath;

    // Upload image to Supabase if local file
    if (_imagePath != null && !kIsWeb && !_imagePath!.startsWith('http')) {
      final file = File(_imagePath!);
      final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final url = await helper.uploadImage(file, fileName);
      if (url != null) finalImagePath = url;
    }

    if (widget.existing == null) {
      final newItem = FirstAid(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        imagePath: finalImagePath,
      );
      await helper.createFirstAid(newItem);
    } else {
      final updated = widget.existing!;
      updated.title = _titleController.text.trim();
      updated.description = _descriptionController.text.trim();
      updated.instructions = _instructionsController.text.trim();
      updated.imagePath = finalImagePath;
      updated.updatedAt = DateTime.now();
      await helper.updateFirstAid(updated);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Topic" : "Add Topic")),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter a title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Short description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter a description" : null,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions', alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter instructions" : null,
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              if (!kIsWeb)
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Select Image"),
                ),
              const SizedBox(height: 10),
              if (_imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb || _imagePath!.startsWith('http')
                      ? Image.network(_imagePath!, height: 150, fit: BoxFit.cover)
                      : Image.file(File(_imagePath!), height: 150, fit: BoxFit.cover),
                ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const CircularProgressIndicator() : Text(isEditing ? "Update" : "Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
