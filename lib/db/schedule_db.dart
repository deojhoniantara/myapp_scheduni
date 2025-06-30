import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/schedule.dart';

class ScheduleDB {
  static final ScheduleDB instance = ScheduleDB._init();
  static Database? _database;

  ScheduleDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('schedule.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT,
        title TEXT,
        date TEXT,
        time TEXT,
        location TEXT,
        description TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop the old table and recreate without reminderMinutes column
      await db.execute('DROP TABLE IF EXISTS schedules');
      await _createDB(db, newVersion);
    }
  }

  Future<int> insertSchedule(Schedule schedule) async {
    final db = await instance.database;
    return await db.insert('schedules', schedule.toMap());
  }

  Future<List<Schedule>> getAllSchedules() async {
    final db = await instance.database;
    final result = await db.query('schedules', orderBy: 'id DESC');
    return result.map((map) => Schedule.fromMap(map)).toList();
  }

  Future<int> updateSchedule(Schedule schedule) async {
    final db = await instance.database;
    return await db.update(
      'schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<int> deleteSchedule(int id) async {
    final db = await instance.database;
    return await db.delete(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllSchedules() async {
    final db = await instance.database;
    return await db.delete('schedules');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
} 