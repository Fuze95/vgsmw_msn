import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/note_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/label_provider.dart';
import '../models/note.dart';
import '../models/label.dart';
import '../widgets/loading_overlay.dart';
import '../utils/image_helper.dart';
import '../utils/constants.dart';

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
  String? _selectedLabel;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _imagePath = widget.note?.imagePath;
    _selectedLabel = widget.note?.label;
    _categories = widget.note?.categories ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePath = await ImageHelper.pickAndSaveImage();
    if (imagePath != null) {
      setState(() {
        _imagePath = imagePath;
      });
    }
  }

  void _showLabelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<LabelProvider>(
        builder: (context, labelProvider, child) {
          return AlertDialog(
            title: const Text('Select Label'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.label_off,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    title: Text(
                      'No Label',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    selected: _selectedLabel == null,
                    selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                    onTap: () {
                      setState(() {
                        _selectedLabel = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  ...labelProvider.labels.map((label) {
                    return ListTile(
                      leading: Icon(
                        Icons.label,
                        color: label.color != null
                            ? Color(int.parse(label.color!))
                            : Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        label.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      selected: _selectedLabel == label.name,
                      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                      onTap: () {
                        setState(() {
                          _selectedLabel = label.name;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                  if (labelProvider.labels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No labels created yet.\nGo to Label Management to create labels.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
        ),
      );
      return;
    }

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
        label: _selectedLabel,
        categories: _categories,
        imagePath: _imagePath,
        status: widget.note?.status ?? NoteStatus.active,
      );

      if (widget.note == null) {
        await noteProvider.addNote(note);
      } else {
        await noteProvider.updateNote(note);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
          ),
        );
      }
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
                  // Label Selection
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.label,
                        color: _selectedLabel != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      title: Text(
                        _selectedLabel ?? 'No Label',
                        style: TextStyle(
                          color: _selectedLabel != null
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      subtitle: const Text('Tap to change label'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _showLabelSelectionDialog,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image
                  if (_imagePath != null) ...[
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          File(_imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _imagePath = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Image Button
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
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
}