import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  static Database? _database;

  factory DatabaseHandler() {
    return _instance;
  }

  DatabaseHandler._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'notes_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            created_at TEXT NOT NULL,
            modified_at TEXT NOT NULL,
            label TEXT,
            categories TEXT,
            image_path TEXT,
            status INTEGER DEFAULT 0
          )
        ''');

        // Create indices for better query performance
        await db.execute('CREATE INDEX idx_status ON notes(status)');
        await db.execute('CREATE INDEX idx_created_at ON notes(created_at)');
      },
    );
  }

  Future<int> insertNote(Note note) async {
    final Database db = await database;
    return await db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes',
        orderBy: 'created_at DESC'
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

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

  Future<List<Note>> getNotesByStatus(NoteStatus status) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<List<Note>> getNotesByCategory(String category) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'categories LIKE ?',
      whereArgs: ['%$category%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<Note?> getNoteById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateNote(Note note) async {
    final Database db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateNoteStatus(int id, NoteStatus status) async {
    final Database db = await database;
    return await db.update(
      'notes',
      {'status': status.index},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> cleanupUnusedImages() async {
    // Get all image paths from database
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

    // Get list of all image files in app directory
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(join(appDir.path, 'images'));
    if (!await imageDir.exists()) return;

    // Delete unused image files
    await for (final file in imageDir.list()) {
      if (!usedImages.contains(file.path)) {
        await file.delete();
      }
    }
  }

  Future<void> vacuum() async {
    final Database db = await database;
    await db.execute('VACUUM');
  }

  // Database maintenance methods
  Future<void> performMaintenance() async {
    await cleanupUnusedImages();
    await vacuum();
  }

  // Backup and restore methods
  Future<String> exportDatabase() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return maps.toString();
  }

  Future<void> importDatabase(String data) async {
    final Database db = await database;
    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('notes');

      // Parse and insert new data
      // Note: You'll need to implement proper parsing of your backup format
      // This is just a placeholder implementation
      final List<Map<String, dynamic>> maps = []; // Parse your data here
      for (var map in maps) {
        await txn.insert('notes', map);
      }
    });
  }
}