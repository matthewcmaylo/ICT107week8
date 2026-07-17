import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/note.dart';

// DatabaseHelper wraps a single sqflite Database instance and exposes the
// four CRUD operations (Create, Read, Update, Delete) the Notes screen
// needs. It is a singleton so every part of the app shares one open
// connection instead of opening the file repeatedly.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    // Lazily open the database on first use, then reuse the same connection.
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // sqflite has no native SQLite engine for Windows/Linux desktop, so on
    // those platforms swap in the FFI-based factory instead. Android, iOS,
    // macOS and web keep using the default sqflite factory.
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // SQL DDL: create the notes table the first time the app runs.
        return db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // CREATE: SQL INSERT, returns the auto-generated row id.
  Future<int> insertNote(Note note) async {
    final db = await database;
    return db.insert('notes', note.toMap());
  }

  // READ: SQL SELECT * FROM notes, newest first.
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final rows = await db.query('notes', orderBy: 'id DESC');
    return rows.map((row) => Note.fromMap(row)).toList();
  }

  // UPDATE: SQL UPDATE ... WHERE id = ?
  Future<int> updateNote(Note note) async {
    final db = await database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE: SQL DELETE FROM notes WHERE id = ?
  Future<int> deleteNote(int id) async {
    final db = await database;
    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Bulk insert used by the "Import from JSON" button. Wrapped in a single
  // batch/transaction so importing many rows is fast and atomic.
  Future<void> insertNotes(List<Note> notes) async {
    final db = await database;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert('notes', note.toMap());
    }
    await batch.commit(noResult: true);
  }

  // Wipes the table, used before a fresh JSON import so re-importing
  // doesn't duplicate rows.
  Future<void> deleteAllNotes() async {
    final db = await database;
    await db.delete('notes');
  }
}
