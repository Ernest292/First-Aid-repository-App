// lib/screens/add_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/first_aid.dart';
import '../db/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AddEditScreen extends StatefulWidget {
  final FirstAid? existing;
  const AddEditScreen({Key? key, this.existing}) : super(key: key);

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;
  bool _saving = false;
  String? _imagePath;

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
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return;
    final temp = File(xfile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(xfile.path)}';
    final saved = await temp.copy('${appDir.path}/$fileName');
    setState(() => _imagePath = saved.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final helper = DatabaseHelper.instance;
    if (widget.existing == null) {
      final newItem = FirstAid(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        imagePath: _imagePath,
      );
      await helper.createFirstAid(newItem);
    } else {
      final updated = widget.existing!;
      updated.title = _titleController.text.trim();
      updated.description = _descriptionController.text.trim();
      updated.instructions = _instructionsController.text.trim();
      updated.imagePath = _imagePath;
      await helper.updateFirstAid(updated);
    }

    setState(() => _saving = false);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit First Aid' : 'Add First Aid')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title (e.g. Bleeding)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Short description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a short description' : null,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextFormField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'Instructions (step by step)'),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter instructions' : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Image'),
                  ),
                  const SizedBox(width: 12),
                  if (_imagePath != null)
                    Expanded(child: Text('Image selected', overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const CircularProgressIndicator() : Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
