import 'package:flutter/material.dart';
import 'dart:io';
import '../models/note.dart';
import '../utils/constants.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                child: Image.file(
                  File(note.imagePath!),
                  height: AppConstants.maxImageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            if (note.categories.isNotEmpty) ...[
              Wrap(
                spacing: AppConstants.smallPadding,
                children: note.categories.map((category) {
                  return Chip(
                    label: Text(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            Text(
              'Last modified: ${_formatDate(note.modifiedAt)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: AppConstants.smallFontSize,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              note.content,
              style: const TextStyle(
                fontSize: AppConstants.bodyFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}