import '../../domain/repositories/memory_repository.dart';

class MemoryContextBuilder {
  const MemoryContextBuilder(this._repository);

  final MemoryRepository _repository;

  Future<String> buildContext(String userMessage, {int limit = 5}) async {
    final query = userMessage.trim();
    if (query.isEmpty) return '';
    final directMatches = await _repository.searchMemories(query);
    final candidates = directMatches.isEmpty
        ? await _repository.getAllMemories()
        : directMatches;
    if (candidates.isEmpty) return '';
    final ranked = candidates
        .where((memory) => _score(memory.content, query) > 0 || directMatches.contains(memory))
        .toList(growable: false)
      ..sort((a, b) {
        final relevance = _score(b.content, query).compareTo(_score(a.content, query));
        if (relevance != 0) return relevance;
        return b.importance.compareTo(a.importance);
      });
    final selected = ranked.take(limit).toList(growable: false);
    if (selected.isEmpty) return '';
    final lines = selected.map((memory) => '- [${memory.type.name}, importance ${memory.importance}] ${memory.content}');
    return 'Relevant long-term JARVIS memory:\n${lines.join('\n')}';
  }

  int _score(String content, String query) {
    final contentWords = _words(content).toSet();
    final queryWords = _words(query).toSet();
    return queryWords.where(contentWords.contains).length;
  }

  Iterable<String> _words(String value) {
    return value.toLowerCase().split(RegExp(r'[^a-z0-9ığüşöçİĞÜŞÖÇ]+')).where((word) => word.length > 2);
  }
}
