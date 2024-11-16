import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/loading_provider.dart';
import '../widgets/loading_overlay.dart';
import '../utils/image_helper.dart';
import 'dart:io';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String? _imagePath;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _imagePath = widget.note?.imagePath;
    _categories = widget.note?.categories ?? [];
  }

  Future<void> _pickImage() async {
    final imagePath = await ImageHelper.pickAndSaveImage();
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  Future<void> _saveNote() async {
    final loadingProvider = Provider.of<LoadingProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    loadingProvider.setLoading(true);

    try {
      final note = Note(
        id: widget.note?.id,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
        categories: _categories,
        imagePath: _imagePath,
      );

      if (widget.note == null) {
        await noteProvider.addNote(note);
      } else {
        await noteProvider.updateNote(note);
      }

      Navigator.pop(context);
    } finally {
      loadingProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(
      builder: (context, loadingProvider, child) {
        return LoadingOverlay(
          isLoading: loadingProvider.isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveNote,
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_imagePath != null) ...[
                    Image.file(
                      File(_imagePath!),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesChips(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesChips() {
    return Wrap(
      spacing: 8,
      children: [
        ..._categories.map(
              (category) => Chip(
            label: Text(category),
            onDeleted: () {
              setState(() {
                _categories.remove(category);
              });
            },
          ),
        ),
        ActionChip(
          label: const Icon(Icons.add),
          onPressed: _showAddCategoryDialog,
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final textController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                setState(() {
                  _categories.add(textController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}