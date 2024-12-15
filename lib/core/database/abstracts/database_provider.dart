// lib/core/database/abstracts/database_provider.dart

import 'package:sqflite/sqflite.dart';

abstract class DatabaseProvider {
  /// Get database instance
  Future<Database> get database;

  /// Initialize database
  Future<void> init();

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]);

  /// Insert record
  Future<int> insert(String table, Map<String, dynamic> values);

  /// Query records
  Future<List<Map<String, dynamic>>> query(
      String table, {
        List<String>? columns,
        String? where,
        List<dynamic>? whereArgs,
        String? orderBy,
        int? limit,
        int? offset,
      });

  /// Update records
  Future<int> update(
      String table,
      Map<String, dynamic> values, {
        String? where,
        List<dynamic>? whereArgs,
      });

  /// Delete records
  Future<int> delete(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
      });

  /// Execute within transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action);

  /// Close database connection
  Future<void> close();
}