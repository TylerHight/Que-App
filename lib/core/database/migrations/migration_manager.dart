// lib/core/database/migrations/migration_manager.dart

import 'migration.dart';

class MigrationManager {
  final List<Migration> _migrations;

  const MigrationManager(this._migrations);

  Future<void> migrate(dynamic db, int oldVersion, int newVersion) async {
    // Sort migrations by version
    _migrations.sort((a, b) => a.version.compareTo(b.version));

    if (oldVersion == 0) {
      // Fresh install - run all migrations up to newVersion
      for (var migration in _migrations) {
        if (migration.version <= newVersion) {
          await migration.up(db);
        }
      }
    } else {
      // Upgrading - run migrations between oldVersion and newVersion
      for (var migration in _migrations) {
        if (migration.version > oldVersion && migration.version <= newVersion) {
          await migration.up(db);
        }
      }
    }
  }

  Future<void> rollback(dynamic db, int fromVersion, int toVersion) async {
    // Sort migrations in reverse order for rollback
    _migrations.sort((a, b) => b.version.compareTo(a.version));

    for (var migration in _migrations) {
      if (migration.version <= fromVersion && migration.version > toVersion) {
        await migration.down(db);
      }
    }
  }
}