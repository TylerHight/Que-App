// lib/core/database/migrations/migration.dart

abstract class Migration {
  final int version;

  const Migration(this.version);

  Future<void> up(dynamic db);
  Future<void> down(dynamic db);
}