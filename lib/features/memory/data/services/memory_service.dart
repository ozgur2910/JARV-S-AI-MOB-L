import 'package:hive_flutter/hive_flutter.dart';

import '../models/memory_entry.dart';
import '../../domain/models/memory_type.dart';

class MemoryService {
  MemoryService(this._box);

  final Box<dynamic> _box;

  Future<MemoryEntry> addMemory({
    required String content,
    required MemoryType type,
    required int importance,
    required String source,
  }) async {
    final sanitized = _sanitizeContent(content);
    _validateContent(sanitized);
    _validateSafeToStore(sanitized);
    final existing = _findDuplicate(sanitized);
    final now = DateTime.now();
    if (existing != null) {
      final updated = existing.copyWith(
        content: sanitized,
        type: type,
        importance: _normalizeImportance(importance),
        source: source.trim().isEmpty ? existing.source : source.trim(),
        updatedAt: now,
      );
      await _box.put(updated.id, updated.toJson());
      return updated;
    }
    final memory = MemoryEntry(
      id: 'memory-${now.microsecondsSinceEpoch}',
      content: sanitized,
      type: type,
      createdAt: now,
      updatedAt: now,
      importance: _normalizeImportance(importance),
      source: source.trim().isEmpty ? 'manual' : source.trim(),
    );
    await _box.put(memory.id, memory.toJson());
    return memory;
  }

  Future<MemoryEntry> updateMemory(MemoryEntry memory) async {
    final sanitized = _sanitizeContent(memory.content);
    _validateContent(sanitized);
    _validateSafeToStore(sanitized);
    final updated = memory.copyWith(
      content: sanitized,
      importance: _normalizeImportance(memory.importance),
      updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toJson());
    return updated;
  }

  Future<void> deleteMemory(String id) => _box.delete(id);

  Future<MemoryEntry?> getMemory(String id) async {
    final raw = _box.get(id);
    if (raw is Map<dynamic, dynamic>) return MemoryEntry.fromJson(raw);
    return null;
  }

  Future<List<MemoryEntry>> getAllMemories() async => _sorted(_readAll());

  Future<List<MemoryEntry>> searchMemories(String query) async {
    final normalized = _normalize(query);
    if (normalized.isEmpty) return getAllMemories();
    return _sorted(
      _readAll().where((memory) => _normalize(memory.content).contains(normalized)).toList(),
    );
  }

  Future<void> clearAllMemories() => _box.clear();

  Future<List<MemoryEntry>> getImportantMemories({int minimumImportance = 4}) async {
    return _sorted(
      _readAll().where((memory) => memory.importance >= minimumImportance).toList(),
    );
  }

  List<MemoryEntry> _readAll() => _box.values
      .whereType<Map<dynamic, dynamic>>()
      .map(MemoryEntry.fromJson)
      .toList(growable: false);

  MemoryEntry? _findDuplicate(String content) {
    final normalized = _normalize(content);
    for (final memory in _readAll()) {
      if (_normalize(memory.content) == normalized) return memory;
    }
    return null;
  }

  List<MemoryEntry> _sorted(List<MemoryEntry> memories) {
    memories.sort((a, b) {
      final importance = b.importance.compareTo(a.importance);
      if (importance != 0) return importance;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return memories;
  }

  String _sanitizeContent(String content) => content.trim().replaceAll(RegExp(r'\s+'), ' ');

  String _normalize(String value) => _sanitizeContent(value).toLowerCase();

  int _normalizeImportance(int importance) => importance.clamp(1, 5).toInt();

  void _validateContent(String content) {
    if (content.isEmpty) throw ArgumentError('Memory content cannot be empty.');
  }

  void _validateSafeToStore(String content) {
    final lower = content.toLowerCase();
    const blocked = [
      'api key',
      'password',
      'auth token',
      'access token',
      'secret key',
      'credential',
    ];
    if (blocked.any(lower.contains)) {
      throw ArgumentError('Sensitive credentials cannot be stored as memory.');
    }
  }
}
