import 'dart:async';
import 'package:booknote/models/book.dart';
import 'package:booknote/models/section.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/note.dart';
import 'models/image.dart';

class DatabaseService {
  Database _db;

  get getDb async {
    if (_db != null) return _db;
    _db = await init();
    return _db;
  }

  Future<Database> init() async {
    var path = await getDatabasesPath();
    String dbPath = join(path, 'book_note.db');
    return await openDatabase(dbPath, onCreate: _onCreate, version: 1);
  }

  String _createUsersTable() {
    return "CREATE TABLE users("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "name TEXT,"
        "email TEXT,"
        "password TEXT);";
  }

  String _createBooksTable() {
    return "CREATE TABLE books("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "name TEXT,"
        "cover_path TEXT,"
        "user_id INTEGER);";
  }

  String _createSectionsTable() {
    return "CREATE TABLE sections("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "name TEXT,"
        "book_id iNTEGER);";
  }

  String _createNotesTable() {
    return "CREATE TABLE notes("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "section_id INTEGER,"
        "book_id INTEGER, page_num INTEGER, "
        "title TEXT, content TEXT);";
  }

  String _createImagesTable() {
    return "CREATE TABLE images("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
        "path TEXT,"
        "note_id INTEGER,"
        "section_id INTEGER,"
        "book_id INTEGER);";
  }

  void _onCreate(Database db, int version) async {
    await db.execute(_createUsersTable());
    await db.execute(_createBooksTable());
    await db.execute(_createSectionsTable());
    await db.execute(_createNotesTable());
    await db.execute(_createImagesTable());
  }

  Future<int> insert(String table, var model) async {
    String sql = _mapToQuery(table, model.toMap());
    List<dynamic> args = model.toMap().values.toList();
    Database db = await getDb;
    try {
      int id = await db.rawInsert(sql, args);
      print('inserted record');
      return id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future update(String table, int id, var model) async {
    Database db = await getDb;
    try {
      await db.update(
        table,
        model.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print(e.toString());
    }
    if (table == 'notes') {
      db.rawUpdate('UPDATE images SET section_id = ? WHERE note_id = ?',
          [model.sectionId, model.id]);
    }
  }

  Future delete(String table, int id) async {
    Database db = await getDb;
    if (table == 'books') {
      _deleteSections(id);
      _deleteNotesOf('book_id', id);
      _deleteImagesOf('book_id', id);
    } else if (table == 'sections') {
      _deleteNotesOf('section_id', id);
      _deleteImagesOf('section_id', id);
    } else if (table == 'notes') {
      _deleteImagesOf('note_id', id);
    }
    try {
      await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future _deleteImagesOf(String col, int id) async {
    Database db = await getDb;
    try {
      db.delete('images', where: '$col=?', whereArgs: [id]);
      print('all images deleted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future _deleteNotesOf(String col, int id) async {
    Database db = await getDb;
    try {
      await db.delete('notes', where: '$col=?', whereArgs: [id]);
      print('all notes deleted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future _deleteSections(int bookId) async {
    Database db = await getDb;
    try {
      await db.delete('sections', where: 'book_id=?', whereArgs: [bookId]);
      print('all sections deleted');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<MyImage>> getImages(int noteId) async {
    Database db = await getDb;
    List<Map<String, dynamic>> data = await db.query(
      'images',
      where: 'note_id = ?',
      whereArgs: [noteId],
    );
    List<MyImage> images = List<MyImage>();
    for (int i = 0; i < data.length; i++) {
      images.add(MyImage.fromMap(data[i]));
    }
    return images;
  }

  Future<List<Book>> getBooks() async {
    Database db = await getDb;
    List<Map<String, dynamic>> data = await db.query('books');
    List<Book> books = List<Book>();
    for (int i = 0; i < data.length; i++) {
      books.add(Book.fromMap(data[i]));
    }
    return books;
  }

  Future<List<Section>> getSections(int bookId) async {
    Database db = await getDb;
    List<Map<String, dynamic>> data = await db.query('sections',
        where: 'book_'
            'id=?',
        whereArgs: [bookId]);
    List<Section> sections = List<Section>();
    for (int i = 0; i < data.length; i++) {
      sections.add(Section.fromMap(data[i]));
    }
    return sections;
  }

  Future<List<Note>> getNotesOf(int bookId, int sectionId) async {
    Database db = await getDb;
    List<Map<String, dynamic>> data = await db.query(
      'notes',
      where: 'book_id = ? AND section_id = ?',
      whereArgs: [bookId, sectionId],
    );
    List<Note> notes = List<Note>();
    for (int i = 0; i < data.length; i++) {
      notes.add(Note.fromMap(data[i]));
    }
    return notes;
  }

  Future<List<Note>> getAllNotes(int bookId) async {
    Database db = await getDb;
    List<Map<String, dynamic>> data = await db.query(
      'notes',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    List<Note> notes = List<Note>();
    for (int i = 0; i < data.length; i++) {
      notes.add(Note.fromMap(data[i]));
    }
    return notes;
  }

  Future<List<Book>> searchBook(String word) async {
    Database db = await getDb;
    List<Book> books = List<Book>();
    List<Map<String, dynamic>> data =
        await db.query('books', where: 'name LIKE ?', whereArgs: [word + '%']);
    for (int i = 0; i < data.length; i++) {
      books.add(Book.fromMap(data[i]));
    }
    return books;
  }

  Future<List<Note>> searchNote(String word, int bookId) async {
    Database db = await getDb;
    List<Note> notes = List<Note>();
    List<Map<String, dynamic>> data = await db.query('notes',
        where: 'title LIKE ? AND book_id = ?', whereArgs: [word + '%', bookId]);
    for (int i = 0; i < data.length; i++) {
      notes.add(Note.fromMap(data[i]));
    }
    return notes;
  }

  String _mapToQuery(String table, Map<String, dynamic> data) {
    List<String> keys = data.keys.toList();
    List<dynamic> values = data.values.toList();
    String sql = 'INSERT INTO $table(';
    for (int i = 0; i < keys.length; i++) {
      if (i > 0) {
        sql += ', ';
      }
      sql += keys[i];
    }
    sql += ') VALUES(';
    for (int i = 0; i < values.length; i++) {
      if (i > 0) {
        sql += ', ';
      }
      sql += '?';
    }
    sql += ');';
    return sql;
  }

  Future drop() async {
    var path = await getDatabasesPath();
    String dbPath = join(path, 'book_note.db');
    deleteDatabase(dbPath);
    print('DB deleted');
  }
}
