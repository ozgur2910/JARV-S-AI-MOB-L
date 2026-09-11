import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/memory_entry.dart';
import '../../domain/models/memory_type.dart';
import '../../domain/repositories/memory_repository.dart';

class MemoryState {
  const MemoryState({this.memories = const [], this.isLoading = false, this.errorMessage});

  final List<MemoryEntry> memories;
  final bool isLoading;
  final String? errorMessage;

  MemoryState copyWith({List<MemoryEntry>? memories, bool? isLoading, String? errorMessage, bool clearError = false}) {
    return MemoryState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MemoryController extends StateNotifier<MemoryState> {
  MemoryController(this._repository) : super(const MemoryState());

  final MemoryRepository _repository;

  Future<void> loadMemories() async => _guard(() async {
        state = state.copyWith(memories: await _repository.getAllMemories());
      });

  Future<void> addMemory({required String content, required MemoryType type, required int importance, String source = 'manual'}) async => _guard(() async {
        await _repository.addMemory(content: content, type: type, importance: importance, source: source);
        state = state.copyWith(memories: await _repository.getAllMemories());
      });

  Future<void> updateMemory(MemoryEntry memory) async => _guard(() async {
        await _repository.updateMemory(memory);
        state = state.copyWith(memories: await _repository.getAllMemories());
      });

  Future<void> deleteMemory(String id) async => _guard(() async {
        await _repository.deleteMemory(id);
        state = state.copyWith(memories: await _repository.getAllMemories());
      });

  Future<void> searchMemories(String query) async => _guard(() async {
        state = state.copyWith(memories: await _repository.searchMemories(query));
      });

  Future<void> clearAllMemories() async => _guard(() async {
        await _repository.clearAllMemories();
        state = state.copyWith(memories: const []);
      });

  Future<void> _guard(Future<void> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
