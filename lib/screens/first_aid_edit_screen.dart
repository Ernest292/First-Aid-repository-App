import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/firts_aid_controller.dart';
import '../models/first_aid_case.dart';
import '../services/supabase_service.dart';

class FirstAidEditScreen extends StatefulWidget {
  final FirstAidCase? existing;
  final Function onSaved;

  const FirstAidEditScreen({
    super.key,
    this.existing,
    required this.onSaved,
  });

  @override
  State<FirstAidEditScreen> createState() => _FirstAidEditScreenState();
}

class _FirstAidEditScreenState extends State<FirstAidEditScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? selectedImageBytes;
  final picker = ImagePicker();
  final controller = FirstAidController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _descController.text = widget.existing!.description;
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;

    if (picked != null) {
      final bytes = await picked.readAsBytes(); // works web + mobile
      setState(() {
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> save() async {
    String? uploadedPath = widget.existing?.imagePath;

    // Upload new image to Supabase
    if (selectedImageBytes != null) {
      uploadedPath = await SupabaseService.uploadImage(selectedImageBytes!);
    }

    if (widget.existing == null) {
      await controller.addCase(
        _titleController.text,
        _descController.text,
        uploadedPath,
      );
    } else {
      await controller.updateCase(
        widget.existing!.id,
        _titleController.text,
        _descController.text,
        uploadedPath,
      );
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Auto-resize values
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.9;
    final imageHeight = imageWidth * 0.6; // 16:9 ratio

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? "Add First Aid Case" : "Edit Case"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 15),

              // Description
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),

              // IMAGE BLOCK — Auto Resizing with rounding
              if (selectedImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.memory(
                    selectedImageBytes!,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.existing?.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    SupabaseService.getPublicImageUrl(widget.existing!.imagePath!),
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Choose Image"),
              ),

              const SizedBox(height: 100),

              ElevatedButton(
                onPressed: save,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
