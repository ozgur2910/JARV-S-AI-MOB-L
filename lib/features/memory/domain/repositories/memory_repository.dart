import '../../data/models/memory_entry.dart';
import '../models/memory_type.dart';

abstract class MemoryRepository {
  Future<MemoryEntry> addMemory({
    required String content,
    required MemoryType type,
    required int importance,
    required String source,
  });

  Future<MemoryEntry> updateMemory(MemoryEntry memory);

  Future<void> deleteMemory(String id);

  Future<MemoryEntry?> getMemory(String id);

  Future<List<MemoryEntry>> getAllMemories();

  Future<List<MemoryEntry>> searchMemories(String query);

  Future<void> clearAllMemories();

  Future<List<MemoryEntry>> getImportantMemories({int minimumImportance = 4});
}
