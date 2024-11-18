import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/label.dart';

// DatabaseHandler implements SQLite database operations for notes and labels
// Uses Singleton pattern to ensure single database instance
class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  static Database? _database;

  factory DatabaseHandler() {
    return _instance;
  }

  DatabaseHandler._internal();

  // Gets existing database instance or initializes a new one
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // Initializes database with notes and labels tables
  // Creates necessary indices for query optimization
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        // Create notes table with columns for title, content, timestamps, etc.
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            modified_at TEXT NOT NULL,
            label TEXT,
            image_path TEXT,
            status INTEGER DEFAULT 0
          )
        ''');

        // Create labels table with unique name constraint
        await db.execute('''
          CREATE TABLE labels(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');

        // Create indices for optimizing common queries
        await db.execute('CREATE INDEX idx_status ON notes(status)');
        await db.execute('CREATE INDEX idx_created_at ON notes(created_at)');
        await db.execute('CREATE INDEX idx_label_name ON labels(name)');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Migration: Add labels table for version 2
          await db.execute('''
            CREATE TABLE labels(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL UNIQUE
            )
          ''');
          await db.execute('CREATE INDEX idx_label_name ON labels(name)');
        }
      },
    );
  }

  // CRUD Operations for Notes

  // Creates a new note in the database
  // Returns the ID of the inserted note
  Future<int> insertNote(Note note) async {
    final Database db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves all notes ordered by creation date
  Future<List<Note>> getNotes() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes',
        orderBy: 'created_at DESC'
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Searches notes by title or content
  // Returns matching notes ordered by creation date
  Future<List<Note>> searchNotes(String query) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Updates an existing note
  // Returns number of rows affected
  Future<int> updateNote(Note note) async {
    final Database db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Deletes a note by ID
  // Returns number of rows affected
  Future<int> deleteNote(int id) async {
    final Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Labels

  // Creates a new label
  // Returns the ID of the inserted label
  Future<int> insertLabel(Label label) async {
    final Database db = await database;
    return await db.insert(
      'labels',
      label.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieves all labels alphabetically
  Future<List<Label>> getLabels() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'labels',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Label.fromMap(maps[i]));
  }

  // Updates an existing label
  // Returns number of rows affected
  Future<int> updateLabel(Label label) async {
    final Database db = await database;
    return await db.update(
      'labels',
      label.toMap(),
      where: 'id = ?',
      whereArgs: [label.id],
    );
  }

  // Deletes a label and removes it from associated notes
  // Returns number of rows affected in labels table
  Future<int> deleteLabel(int id) async {
    final Database db = await database;
    // First, remove the label from any notes using it
    await db.update(
      'notes',
      {'label': null},
      where: 'label IN (SELECT name FROM labels WHERE id = ?)',
      whereArgs: [id],
    );
    // Then delete the label
    return await db.delete(
      'labels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Maintenance Operations

  // Cleans up unused image files from storage
  Future<void> cleanupUnusedImages() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      columns: ['image_path'],
      where: 'image_path IS NOT NULL',
    );

    final Set<String> usedImages = maps
        .map((map) => map['image_path'] as String?)
        .where((path) => path != null)
        .toSet() as Set<String>;

    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(join(appDir.path, 'images'));
    if (!await imageDir.exists()) return;

    await for (final file in imageDir.list()) {
      if (!usedImages.contains(file.path)) {
        await file.delete();
      }
    }
  }

  // Performs database optimization
  Future<void> vacuum() async {
    final Database db = await database;
    await db.execute('VACUUM');
  }

  // Exports database content for backup
  Future<Map<String, dynamic>> exportDatabase() async {
    final Database db = await database;
    final List<Map<String, dynamic>> noteMaps = await db.query('notes');
    final List<Map<String, dynamic>> labelMaps = await db.query('labels');

    return {
      'notes': noteMaps,
      'labels': labelMaps,
      'version': 2,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Imports database content from backup (not implemented, for the future)
  // Replaces all existing data
  Future<void> importDatabase(Map<String, dynamic> data) async {
    final Database db = await database;
    await db.transaction((txn) async {
      await txn.delete('notes');
      await txn.delete('labels');

      final List<Map<String, dynamic>> labelMaps =
      List<Map<String, dynamic>>.from(data['labels'] ?? []);
      for (var map in labelMaps) {
        await txn.insert('labels', map);
      }

      final List<Map<String, dynamic>> noteMaps =
      List<Map<String, dynamic>>.from(data['notes'] ?? []);
      for (var map in noteMaps) {
        await txn.insert('notes', map);
      }
    });
  }
}