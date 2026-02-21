import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../pdf/pdf_helper.dart';

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
        created_at TEXT,
        is_laporan INTEGER DEFAULT 0,
        jenis_laporan TEXT,
        tanggal_export TEXT
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
        jenis_laporan TEXT,
        tanggal_export TEXT,
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
      SELECT bulan, total, jenis, sort_date FROM (
        SELECT tanggal_export AS bulan, COUNT(*) AS total, 'manual' AS jenis, tanggal_export AS sort_date
        FROM laporan
        WHERE jenis_laporan = 'manual'
        GROUP BY tanggal_export
        UNION ALL
        SELECT bulan_laporan AS bulan, COUNT(*) AS total, 'otomatis' AS jenis, (bulan_laporan || '-01') AS sort_date
        FROM laporan
        WHERE jenis_laporan = 'otomatis' OR jenis_laporan IS NULL
        GROUP BY bulan_laporan
      ) ORDER BY sort_date DESC
    ''');
  }

    static Future<int> updatePeminjamanToLaporanManual(
      int id, String tanggalExport) async {
    final db = await database;
    return await db.update(
      'peminjaman',
      {
        'is_laporan': 1,
        'jenis_laporan': 'manual',
        'tanggal_export': tanggalExport,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  static Future<int> updatePeminjamanToLaporanOtomatis(
    int id, String tanggalExport) async {
  final db = await database;
  return await db.update(
    'peminjaman',
    {
      'is_laporan': 1,
      'jenis_laporan': 'otomatis',
      'tanggal_export': tanggalExport,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

  static Future<void> exportManualMany(List<int> ids) async {
    final db = await database;

    final now = DateTime.now();
    final tanggalExport = now.toIso8601String();

    for (var id in ids) {
      final dataList = await db.query(
        'peminjaman',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (dataList.isEmpty) continue;

      final data = dataList.first;

      final tanggal = DateTime.parse(data['tanggal_pinjam'] as String);
      final bulanData =
          "${tanggal.year}-${tanggal.month.toString().padLeft(2, '0')}";

      await db.insert(
        'laporan',
        {
          'id': data['id'],
          'nama_barang': data['nama_barang'],
          'nama_peminjam': data['nama_peminjam'],
          'kelas': data['kelas'],
          'instansi': data['instansi'],
          'tanggal_pinjam': data['tanggal_pinjam'],
          'tanggal_kembali': data['tanggal_kembali'],
          'foto_path': data['foto_path'],
          'created_at': data['created_at'],
          'jenis_laporan': 'manual',
          'tanggal_export': tanggalExport, 
          'bulan_laporan': bulanData,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      await db.update(
        'peminjaman',
        {
          'is_laporan': 1,
          'jenis_laporan': 'manual',
          'tanggal_export': tanggalExport,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
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
  // ================= EXPORT PDF =================

  static Future<String?> exportPdfManual(String tanggalExport) async {
    final db = await database;

    final data = await db.query(
      'laporan',
      where: 'jenis_laporan = ? AND tanggal_export = ?',
      whereArgs: ['manual', tanggalExport],
    );

    if (data.isEmpty) return null;

    final path = await PdfHelper.generateLaporanPdf(
      data,
      title: "Laporan Manual",
    );
    return path;
  }

  static Future<String?> exportPdfBulanan(String bulan) async {
    final data = await getPeminjamanByBulan(bulan);
    if (data.isEmpty) return null;

    final path = await PdfHelper.generateLaporanPdf(
      data,
      title: "Laporan Bulan $bulan",
    );
    return path;
  }
}
