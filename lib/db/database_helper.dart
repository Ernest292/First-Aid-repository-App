// lib/db/database_helper.dart
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/first_aid.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

Future<void> seedAdditionalTopics(Database db) async {
  final data = await rootBundle.loadString('assets/preloaded.json');
  final List list = json.decode(data);
  final now = DateTime.now().toIso8601String();

  for (final item in list) {
    await db.insert(DatabaseHelper.tableFirstAid, {
      'title': item['title'],
      'description': item['description'],
      'instructions': item['instructions'],
      'image_path': null,
      'created_at': now,
      'updated_at': now,
    });
  }
}
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String tableFirstAid = 'first_aid';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('first_aid.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, fileName);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableFirstAid (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      instructions TEXT NOT NULL,
      image_path TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    ''');

    // Seed initial templates
    final now = DateTime.now().toIso8601String();
    final seed = [
      {
        'title': 'Bleeding (External)',
        'description': 'How to manage external bleeding',
        'instructions': '1. Apply direct pressure with a clean cloth.\n2. Elevate the injured area if possible.\n3. Maintain pressure until bleeding slows.\n4. Seek medical help for severe bleeding.',
        'image_path': null,
      },
      {
        'title': 'Burns (Minor)',
        'description': 'Treating minor burns',
        'instructions': '1. Cool the burn under running water for 10-20 minutes.\n2. Remove tight items like rings.\n3. Cover with sterile non-stick dressing.\n4. Do NOT apply ice or butter.',
        'image_path': null,
      },
      {
        'title': 'Choking (Adult)',
        'description': 'First aid for a choking adult who cant breathe',
      'instructions': '1. Ask “Are you choking?” If they cannot speak, call for help.\n2. Perform 5 back blows between the shoulder blades.\n3. Give 5 abdominal thrusts (Heimlich maneuver).\n4. Alternate until object dislodged or they become unresponsive.',
        'image_path': null,
      },
      {
        'title': 'Fracture (Suspected)',
        'description': 'Stabilize a suspected broken bone',
        'instructions': '1. Keep the person still and calm.\n2. Immobilize the area using a splint or padding.\n3. Apply ice packs to reduce swelling, not directly on skin.\n4. Seek urgent medical attention.',
        'image_path': null,
      }
    ];

    for (final item in seed) {
      await db.insert(tableFirstAid, {
        'title': item['title'],
        'description': item['description'],
        'instructions': item['instructions'],
        'image_path': item['image_path'],
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<FirstAid> createFirstAid(FirstAid item) async {
    final db = await instance.database;
    final id = await db.insert(tableFirstAid, item.toMap());
    item.id = id;
    return item;
  }

  Future<FirstAid?> readFirstAid(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableFirstAid,
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FirstAid.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<FirstAid>> readAllFirstAids({String? query}) async {
    final db = await instance.database;
    String whereString = '';
    List<dynamic> whereArgs = [];
    if (query != null && query.trim().isNotEmpty) {
      whereString = 'WHERE title LIKE ? OR description LIKE ?';
      final q = '%${query.trim()}%';
      whereArgs = [q, q];
    }
    final result = await db.rawQuery(
      'SELECT * FROM $tableFirstAid ${whereString.isNotEmpty ? whereString : ''} ORDER BY updated_at DESC',
      whereArgs,
    );
    return result.map((m) => FirstAid.fromMap(m)).toList();
  }

  Future<int> updateFirstAid(FirstAid item) async {
    final db = await instance.database;
    item.updatedAt = DateTime.now();
    return db.update(
      tableFirstAid,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteFirstAid(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableFirstAid,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;
  Future<Database> get database async => _db ??= await _initDB();

  static const String _tableName = 'first_aid';

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'first_aid.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            steps TEXT NOT NULL,
            favorite INTEGER NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
      onOpen: (db) async {
        // seed data if empty
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
        );
        if (count == 0) {
          await _seedData(db);
        }
      },
    );
  }

  Future<void> _seedData(Database db) async {
    final items = [
      FirstAid(
        title: 'CPR (Adult)',
        description: 'Cardiopulmonary resuscitation for adults.',
        instructions:
        '1. Check responsiveness.\n2. Call emergency services.\n3. Start chest compressions: 30 compressions at 100-120/min.\n4. Give 2 rescue breaths (if trained).\n5. Continue until help arrives.',
      ),
      FirstAid(
        title: 'Severe Bleeding',
        description: 'Control severe bleeding to prevent shock.',
        instructions:
        '1. Apply direct pressure with clean cloth.\n2. Elevate the wounded area if possible.\n3. If bleeding soaks through, add more cloth — do NOT remove old ones.\n4. Use a tourniquet only if life-threatening and trained.\n5. Seek immediate medical help.',
      ),
      FirstAid(
        title: 'Burns (Minor)',
        description: 'Treat minor first-degree and superficial second-degree burns.',
        instructions:
        '1. Cool the burn with running cool (not cold) water for 10–20 minutes.\n2. Remove jewelry and tight items.\n3. Cover with sterile, non-stick dressing.\n4. Avoid ice and do not break blisters.\n5. Seek care for larger or severe burns.',
      ),
    ];

    for (var item in items) {
      await db.insert(_tableName, item.toMap());
    }
  }

  Future<List<FirstAid>> getAll({String? query}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      maps = await db.query(
        _tableName,
        where: 'title LIKE ? OR description LIKE ? OR steps LIKE ?',
        whereArgs: [q, q, q],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query(_tableName, orderBy: 'favorite DESC, created_at DESC');
    }
    return maps.map((m) => FirstAid.fromMap(m)).toList();
  }

  Future<int> insert(FirstAid item) async {
    final db = await database;
    return await db.insert(_tableName, item.toMap());
  }

  Future<int> update(FirstAid item) async {
    final db = await database;
    return await db.update(_tableName, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FirstAid>> getFavorites() async {
    final db = await database;
    final maps =
    await db.query(_tableName, where: 'favorite = ?', whereArgs: [1], orderBy: 'created_at DESC');
    return maps.map((m) => FirstAid.fromMap(m)).toList();
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
