// lib/providers/note_provider.dart
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../database/database_handler.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes.where((note) => note.status == NoteStatus.active).toList();
  List<Note> get archivedNotes => _notes.where((note) => note.status == NoteStatus.archived).toList();

  Set<String> get allCategories =>
      _notes.expand((note) => note.categories).toSet();

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final DatabaseHandler _databaseHandler;

  NoteProvider(this._databaseHandler) {
    _loadNotes();
  }

  // Add this method
  Future<void> _loadNotes() async {
    try {
      _notes = await _databaseHandler.getNotes();
      notifyListeners();
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
      notifyListeners();
    }
  }

  List<Note> getFilteredNotes() {
    return _notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch && note.status == NoteStatus.active;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleArchiveStatus(Note note) async {
    note.status = note.status == NoteStatus.active
        ? NoteStatus.archived
        : NoteStatus.active;
    await updateNote(note);
  }

  Future<void> addCategory(Note note, String category) async {
    if (!note.categories.contains(category)) {
      note.categories.add(category);
      await updateNote(note);
    }
  }

  Future<void> removeCategory(Note note, String category) async {
    note.categories.remove(category);
    await updateNote(note);
  }

  Future<void> updateImagePath(Note note, String? imagePath) async {
    note.imagePath = imagePath;
    await updateNote(note);
  }

  Future<void> addNote(Note note) async {
    await _databaseHandler.insertNote(note);
    await _loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _databaseHandler.updateNote(note);
    await _loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _databaseHandler.deleteNote(id);
    await _loadNotes();
  }

  // Method to refresh notes from database
  Future<void> refreshNotes() async {
    await _loadNotes();
  }
}