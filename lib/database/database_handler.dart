import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler{
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'msn.db'),
      onCreate: (database , version) async {
        await database.execute("CREATE TABLE user(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL)");
      }

    );
  }

}