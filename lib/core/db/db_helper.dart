import 'package:notes_todo_app/core/model/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import '../models/note_model.dart';

class DBHelper {
  static Future<Database> _openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    return openDatabase(
      join(dir.path, 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, content TEXT, timestamp TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertNote(Note note) async {
    final db = await _openDB();
    await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Note>> getNotes() async {
    final db = await _openDB();
    final maps = await db.query('notes');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  static Future<void> deleteNote(int id) async {
    final db = await _openDB();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateNote(Note note) async {
    final db = await _openDB();
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }
}
