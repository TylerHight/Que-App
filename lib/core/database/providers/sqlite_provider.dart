// lib/core/database/providers/sqlite_provider.dart

import 'package:sqflite/sqflite.dart';
import '../abstracts/database_provider.dart';
import '../migrations/migration_service.dart';

class SQLiteProvider implements DatabaseProvider {
  static final SQLiteProvider _instance = SQLiteProvider._internal();
  factory SQLiteProvider() => _instance;

  Database? _database;

  SQLiteProvider._internal();

  @override
  Future<Database> get database async {
    _database ??= await MigrationService.initializeDatabase();
    return _database!;
  }

  @override
  Future<void> init() async {
    await database;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
      String table, {
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? orderBy,
        int? limit,
        int? offset,
      }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  @override
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> reset() async {
    await close();
    await MigrationService.resetDatabase();
  }
}