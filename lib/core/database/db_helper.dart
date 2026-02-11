import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static const String _dbName = 'assestra.db';
  static const int _dbVersion = 3; // 🔥 naikkan versi

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
    // 🔹 Tabel peminjaman
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

    // 🔹 Tabel laporan (ARSIP)
    await db.execute('''
      CREATE TABLE laporan (
        id INTEGER,
        nama_barang TEXT,
        nama_peminjam TEXT,
        kelas TEXT,
        instansi TEXT,
        tanggal_pinjam TEXT,
        tanggal_kembali TEXT,
        foto_path TEXT,
        created_at TEXT,
        bulan_laporan TEXT
      )
    ''');
  }

  // ================= MIGRATION =================

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE peminjaman ADD COLUMN foto_path TEXT');
      await db.execute(
          'ALTER TABLE peminjaman ADD COLUMN created_at TEXT');
    }

    // 🔥 Tambah tabel laporan jika belum ada
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS laporan (
          id INTEGER,
          nama_barang TEXT,
          nama_peminjam TEXT,
          kelas TEXT,
          instansi TEXT,
          tanggal_pinjam TEXT,
          tanggal_kembali TEXT,
          foto_path TEXT,
          created_at TEXT,
          bulan_laporan TEXT
        )
      ''');
    }
  }

  // ================= AUTO ARSIP =================

  static Future<void> autoArsipBulanLalu() async {
    final db = await database;

    final now = DateTime.now();
    final bulanSekarang =
        "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // Ambil data bulan lalu
    final dataLama = await db.query(
      'peminjaman',
      where: "strftime('%Y-%m', tanggal_pinjam) != ?",
      whereArgs: [bulanSekarang],
    );

    if (dataLama.isEmpty) return;

    for (var data in dataLama) {
      final tanggal =
          DateTime.parse(data['tanggal_pinjam'] as String);

      final bulanData =
          "${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}";

      await db.insert(
        'laporan',
        {
          ...data,
          'bulan_laporan': bulanData,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // Hapus dari tabel utama
    await db.delete(
      'peminjaman',
      where: "strftime('%Y-%m', tanggal_pinjam) != ?",
      whereArgs: [bulanSekarang],
    );
  }

  // ================= LAPORAN =================

  static Future<List<Map<String, dynamic>>> getPeminjamanByBulan(
      String bulan) async {
    final db = await database;

    return await db.query(
      'laporan',
      where: 'bulan_laporan = ?',
      whereArgs: [bulan],
    );
  }

  static Future<List<Map<String, dynamic>>> getLaporanBulanan() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT bulan_laporan AS bulan,
      COUNT(*) AS total
      FROM laporan
      GROUP BY bulan_laporan
      ORDER BY bulan_laporan DESC
    ''');
  }

  // ================= CRUD =================

  static Future<int> insertPeminjaman(
      Map<String, dynamic> data) async {
    final db = await database;

    data['created_at'] =
        DateTime.now().toIso8601String();

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

  static Future<int> deletePeminjaman(int id) async {
    final db = await database;

    return await db.delete(
      'peminjaman',
      where: 'id = ?',
      whereArgs: [id],
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

}
