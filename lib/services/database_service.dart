import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/muvekkil.dart';
import '../models/dava.dart';
import '../models/gorev.dart';
import '../models/etkinlik.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'avukat_is_takip.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Müvekkil tablosu
    await db.execute('''
      CREATE TABLE muvekkil (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ad TEXT NOT NULL,
        soyad TEXT NOT NULL,
        email TEXT,
        telefon TEXT,
        adres TEXT,
        tc_kimlik TEXT,
        notlar TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        avatar TEXT
      )
    ''');

    // Dava tablosu
    await db.execute('''
      CREATE TABLE dava (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dava_no TEXT NOT NULL,
        baslik TEXT NOT NULL,
        aciklama TEXT,
        durum INTEGER NOT NULL,
        tur INTEGER NOT NULL,
        muvekkil_id INTEGER NOT NULL,
        dava_tarihi INTEGER,
        durusma_tarihi INTEGER,
        mahkeme TEXT,
        hakim TEXT,
        karsi_taraf TEXT,
        karsi_taraf_avukat TEXT,
        ucret REAL,
        notlar TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        dosya_yolu TEXT,
        FOREIGN KEY (muvekkil_id) REFERENCES muvekkil (id)
      )
    ''');

    // Görev tablosu
    await db.execute('''
      CREATE TABLE gorev (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baslik TEXT NOT NULL,
        aciklama TEXT,
        durum INTEGER NOT NULL,
        oncelik INTEGER NOT NULL,
        dava_id INTEGER,
        baslangic_tarihi INTEGER,
        bitis_tarihi INTEGER,
        tamamlanma_tarihi INTEGER,
        hatirlatici_var INTEGER NOT NULL,
        hatirlatici_tarihi INTEGER,
        notlar TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dava_id) REFERENCES dava (id)
      )
    ''');

    // Etkinlik tablosu
    await db.execute('''
      CREATE TABLE etkinlik (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baslik TEXT NOT NULL,
        aciklama TEXT,
        tur INTEGER NOT NULL,
        baslangic_tarihi INTEGER NOT NULL,
        bitis_tarihi INTEGER,
        dava_id INTEGER,
        konum TEXT,
        katilimcilar TEXT,
        hatirlatici_var INTEGER NOT NULL,
        hatirlatici_tarihi INTEGER,
        notlar TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dava_id) REFERENCES dava (id)
      )
    ''');

    // İndeksler
    await db.execute('CREATE INDEX idx_dava_muvekkil ON dava(muvekkil_id)');
    await db.execute('CREATE INDEX idx_gorev_dava ON gorev(dava_id)');
    await db.execute('CREATE INDEX idx_etkinlik_dava ON etkinlik(dava_id)');
    await db.execute('CREATE INDEX idx_etkinlik_tarih ON etkinlik(baslangic_tarihi)');
  }

  // Müvekkil CRUD
  Future<int> insertMuvekkil(Muvekkil muvekkil) async {
    final db = await database;
    return await db.insert('muvekkil', muvekkil.toMap());
  }

  Future<List<Muvekkil>> getAllMuvekkil() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('muvekkil');
    return List.generate(maps.length, (i) => Muvekkil.fromMap(maps[i]));
  }

  Future<Muvekkil?> getMuvekkilById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'muvekkil',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Muvekkil.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMuvekkil(Muvekkil muvekkil) async {
    final db = await database;
    return await db.update(
      'muvekkil',
      muvekkil.toMap(),
      where: 'id = ?',
      whereArgs: [muvekkil.id],
    );
  }

  Future<int> deleteMuvekkil(int id) async {
    final db = await database;
    return await db.delete(
      'muvekkil',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dava CRUD
  Future<int> insertDava(Dava dava) async {
    final db = await database;
    return await db.insert('dava', dava.toMap());
  }

  Future<List<Dava>> getAllDava() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dava');
    final List<Dava> davalar = [];
    
    for (var map in maps) {
      final dava = Dava.fromMap(map);
      if (dava.muvekkilId != null) {
        final muvekkil = await getMuvekkilById(dava.muvekkilId);
        davalar.add(dava.copyWith(muvekkil: muvekkil));
      } else {
        davalar.add(dava);
      }
    }
    
    return davalar;
  }

  Future<Dava?> getDavaById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dava',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final dava = Dava.fromMap(maps.first);
      if (dava.muvekkilId != null) {
        final muvekkil = await getMuvekkilById(dava.muvekkilId);
        return dava.copyWith(muvekkil: muvekkil);
      }
      return dava;
    }
    return null;
  }

  Future<int> updateDava(Dava dava) async {
    final db = await database;
    return await db.update(
      'dava',
      dava.toMap(),
      where: 'id = ?',
      whereArgs: [dava.id],
    );
  }

  Future<int> deleteDava(int id) async {
    final db = await database;
    return await db.delete(
      'dava',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Görev CRUD
  Future<int> insertGorev(Gorev gorev) async {
    final db = await database;
    return await db.insert('gorev', gorev.toMap());
  }

  Future<List<Gorev>> getAllGorev() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gorev');
    final List<Gorev> gorevler = [];
    
    for (var map in maps) {
      final gorev = Gorev.fromMap(map);
      if (gorev.davaId != null) {
        final dava = await getDavaById(gorev.davaId!);
        gorevler.add(gorev.copyWith(dava: dava));
      } else {
        gorevler.add(gorev);
      }
    }
    
    return gorevler;
  }

  Future<List<Gorev>> getGorevByDavaId(int davaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gorev',
      where: 'dava_id = ?',
      whereArgs: [davaId],
    );
    final List<Gorev> gorevler = [];
    
    for (var map in maps) {
      final gorev = Gorev.fromMap(map);
      final dava = await getDavaById(gorev.davaId!);
      gorevler.add(gorev.copyWith(dava: dava));
    }
    
    return gorevler;
  }

  Future<int> updateGorev(Gorev gorev) async {
    final db = await database;
    return await db.update(
      'gorev',
      gorev.toMap(),
      where: 'id = ?',
      whereArgs: [gorev.id],
    );
  }

  Future<int> deleteGorev(int id) async {
    final db = await database;
    return await db.delete(
      'gorev',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Etkinlik CRUD
  Future<int> insertEtkinlik(Etkinlik etkinlik) async {
    final db = await database;
    return await db.insert('etkinlik', etkinlik.toMap());
  }

  Future<List<Etkinlik>> getAllEtkinlik() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('etkinlik');
    final List<Etkinlik> etkinlikler = [];
    
    for (var map in maps) {
      final etkinlik = Etkinlik.fromMap(map);
      if (etkinlik.davaId != null) {
        final dava = await getDavaById(etkinlik.davaId!);
        etkinlikler.add(etkinlik.copyWith(dava: dava));
      } else {
        etkinlikler.add(etkinlik);
      }
    }
    
    return etkinlikler;
  }

  Future<List<Etkinlik>> getEtkinlikByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'etkinlik',
      where: 'baslangic_tarihi BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    final List<Etkinlik> etkinlikler = [];
    
    for (var map in maps) {
      final etkinlik = Etkinlik.fromMap(map);
      if (etkinlik.davaId != null) {
        final dava = await getDavaById(etkinlik.davaId!);
        etkinlikler.add(etkinlik.copyWith(dava: dava));
      } else {
        etkinlikler.add(etkinlik);
      }
    }
    
    return etkinlikler;
  }

  Future<int> updateEtkinlik(Etkinlik etkinlik) async {
    final db = await database;
    return await db.update(
      'etkinlik',
      etkinlik.toMap(),
      where: 'id = ?',
      whereArgs: [etkinlik.id],
    );
  }

  Future<int> deleteEtkinlik(int id) async {
    final db = await database;
    return await db.delete(
      'etkinlik',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // İstatistikler
  Future<Map<String, int>> getDashboardStats() async {
    final db = await database;
    
    final muvekkilCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM muvekkil')) ?? 0;
    final davaCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dava')) ?? 0;
    final aktifGorevCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM gorev WHERE durum != ?', 
      [GorevDurumu.tamamlandi.index]
    )) ?? 0;
    final bugunEtkinlikCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM etkinlik WHERE DATE(datetime(baslangic_tarihi/1000, \'unixepoch\')) = DATE(\'now\')'
    )) ?? 0;
    
    return {
      'muvekkil': muvekkilCount,
      'dava': davaCount,
      'aktifGorev': aktifGorevCount,
      'bugunEtkinlik': bugunEtkinlikCount,
    };
  }
}
