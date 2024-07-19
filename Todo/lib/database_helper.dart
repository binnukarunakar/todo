import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/list_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('listitems.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE listitems (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL
    )
    ''');
  }

  Future<List<ListItem>> getListItems() async {
    final db = await instance.database;
    final result = await db.query('listitems');
    return result.map((json) => ListItem.fromMap(json)).toList();
  }

  Future<void> insertListItem(ListItem listItem) async {
    final db = await instance.database;
    await db.insert('listitems', listItem.toMap());
  }

  Future<void> updateListItem(ListItem listItem) async {
    final db = await instance.database;
    await db.update(
      'listitems',
      listItem.toMap(),
      where: 'id = ?',
      whereArgs: [listItem.id],
    );
  }

  Future<void> deleteListItem(int id) async {
    final db = await instance.database;
    await db.delete(
      'listitems',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
