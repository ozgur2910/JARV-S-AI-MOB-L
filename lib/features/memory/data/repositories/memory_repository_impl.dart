import '../../domain/models/memory_type.dart';
import '../../domain/repositories/memory_repository.dart';
import '../models/memory_entry.dart';
import '../services/memory_service.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  const MemoryRepositoryImpl(this._service);

  final MemoryService _service;

  @override
  Future<MemoryEntry> addMemory({required String content, required MemoryType type, required int importance, required String source}) {
    return _service.addMemory(content: content, type: type, importance: importance, source: source);
  }

  @override
  Future<void> clearAllMemories() => _service.clearAllMemories();

  @override
  Future<void> deleteMemory(String id) => _service.deleteMemory(id);

  @override
  Future<List<MemoryEntry>> getAllMemories() => _service.getAllMemories();

  @override
  Future<List<MemoryEntry>> getImportantMemories({int minimumImportance = 4}) => _service.getImportantMemories(minimumImportance: minimumImportance);

  @override
  Future<MemoryEntry?> getMemory(String id) => _service.getMemory(id);

  @override
  Future<List<MemoryEntry>> searchMemories(String query) => _service.searchMemories(query);

  @override
  Future<MemoryEntry> updateMemory(MemoryEntry memory) => _service.updateMemory(memory);
}
