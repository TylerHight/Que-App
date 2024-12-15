// lib/core/database/abstracts/crud_repository.dart

abstract class CrudRepository<T> {
  /// Create new record
  Future<T> create(T entity);

  /// Read record by ID
  Future<T?> read(String id);

  /// Update existing record
  Future<bool> update(T entity);

  /// Delete record by ID
  Future<bool> delete(String id);

  /// Get all records
  Future<List<T>> getAll();

  /// Check if record exists
  Future<bool> exists(String id);

  /// Count total records
  Future<int> count();

  /// Delete all records
  Future<void> deleteAll();
}