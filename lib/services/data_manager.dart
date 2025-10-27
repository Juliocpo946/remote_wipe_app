import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'logger.dart';

class DataManager {
  static final DataManager instance = DataManager._();
  DataManager._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensitive_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE documents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> saveUser(String name, String email, String password) async {
    final db = await database;
    await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<void> saveDocument(String title, String content) async {
    final db = await database;
    await db.insert('documents', {
      'title': title,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final db = await database;
    return await db.query('documents');
  }

  Future<void> saveToPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> wipeAllData() async {
    try {
      await _wipeDatabase();
      await _wipePreferences();
      await _wipeFiles();
    } catch (e) {
      Logger.error('data_manager', 'Error durante limpieza de datos', 'WIPE_001');
    }
  }

  Future<void> _wipeDatabase() async {
    try {
      final db = await database;
      await db.delete('users');
      await db.delete('documents');
    } catch (e) {
      Logger.error('data_manager', 'Error limpiando base de datos', 'DB_001');
    }
  }

  Future<void> _wipePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      Logger.error('data_manager', 'Error limpiando preferencias', 'PREFS_001');
    }
  }

  Future<void> _wipeFiles() async {
    try {
      final appDir = Directory.systemTemp;
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
    } catch (e) {
      Logger.error('data_manager', 'Error limpiando archivos temporales', 'FILES_001');
    }
  }
}