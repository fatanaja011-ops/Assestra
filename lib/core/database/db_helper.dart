import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static const String _dbName = 'assestra.db';
  static const int _dbVersion = 2;

  // ================= DATABASE =================

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE =================

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE peminjaman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_barang TEXT NOT NULL,
        nama_peminjam TEXT NOT NULL,
        kelas TEXT NOT NULL,
        instansi TEXT,
        tanggal_pinjam TEXT NOT NULL,
        tanggal_kembali TEXT NOT NULL,
        foto_path TEXT,
        created_at TEXT
      )
    ''');
  }

  // ================= MIGRATION =================

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE peminjaman ADD COLUMN foto_path TEXT',
      );
      await db.execute(
        'ALTER TABLE peminjaman ADD COLUMN created_at TEXT',
      );
    }
  }

  // ================= CRUD =================

  static Future<int> insertPeminjaman(Map<String, dynamic> data) async {
    final db = await database;

    data['created_at'] = DateTime.now().toIso8601String();

    return await db.insert(
      'peminjaman',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllPeminjaman() async {
    final db = await database;
    return await db.query(
      'peminjaman',
      orderBy: 'id DESC',
    );
  }

  static Future<int> updatePeminjaman(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await database;
    return await db.update(
      'peminjaman',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deletePeminjaman(int id) async {
    final db = await database;
    return await db.delete(
      'peminjaman',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
