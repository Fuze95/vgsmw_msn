import 'package:flutter/material.dart';
import 'dart:io';
import '../models/note.dart';
import '../screens/note_detail_screen.dart';
import '../utils/constants.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const NoteCard({
    Key? key,
    required this.note,
    this.onArchive,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppConstants.smallPadding,
        horizontal: AppConstants.defaultPadding,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(note: note),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.imagePath != null) ...[
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.cardRadius),
                ),
                child: Image.file(
                  File(note.imagePath!),
                  height: AppConstants.thumbnailSize,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: AppConstants.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: AppConstants.bodyFontSize,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (note.label != null && note.label!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.smallPadding),
                    Chip(
                      label: Text(
                        note.label!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                      avatar: Icon(
                        Icons.label,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
                bottom: AppConstants.smallPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last modified: ${_formatDate(note.modifiedAt)}',
                    style: TextStyle(
                      fontSize: AppConstants.smallFontSize,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Row(
                    children: [
                      if (onArchive != null)
                        IconButton(
                          icon: const Icon(Icons.archive),
                          onPressed: onArchive,
                          tooltip: 'Archive note',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: onDelete,
                          tooltip: 'Delete note',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}