import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jarvis_ai_mobile/features/memory/data/models/memory_entry.dart';
import 'package:jarvis_ai_mobile/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:jarvis_ai_mobile/features/memory/data/services/memory_command_parser.dart';
import 'package:jarvis_ai_mobile/features/memory/data/services/memory_context_builder.dart';
import 'package:jarvis_ai_mobile/features/memory/data/services/memory_service.dart';
import 'package:jarvis_ai_mobile/features/memory/domain/models/memory_command.dart';
import 'package:jarvis_ai_mobile/features/memory/domain/models/memory_type.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;
  late MemoryRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jarvis_memory_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('memories');
    repository = MemoryRepositoryImpl(MemoryService(box));
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('memory model serializes and restores', () {
    final now = DateTime.utc(2026, 8, 12);
    final memory = MemoryEntry(
      id: 'memory-1',
      content: 'I prefer Turkish.',
      type: MemoryType.preference,
      createdAt: now,
      updatedAt: now,
      importance: 4,
      source: 'test',
    );

    final restored = MemoryEntry.fromJson(memory.toJson());

    expect(restored.id, memory.id);
    expect(restored.content, memory.content);
    expect(restored.type, memory.type);
    expect(restored.importance, memory.importance);
    expect(restored.source, memory.source);
  });

  test('repository updates duplicate memory instead of creating a new one', () async {
    await repository.addMemory(
      content: 'I like dark interfaces',
      type: MemoryType.preference,
      importance: 3,
      source: 'chat',
    );
    await repository.addMemory(
      content: '  I LIKE dark interfaces  ',
      type: MemoryType.preference,
      importance: 5,
      source: 'chat',
    );

    final memories = await repository.getAllMemories();

    expect(memories, hasLength(1));
    expect(memories.single.importance, 5);
  });

  test('search is case-insensitive and delete removes an entry', () async {
    final memory = await repository.addMemory(
      content: 'My office light is in Home Assistant',
      type: MemoryType.general,
      importance: 4,
      source: 'manual',
    );

    expect(await repository.searchMemories('OFFICE'), hasLength(1));
    await repository.deleteMemory(memory.id);
    expect(await repository.getAllMemories(), isEmpty);
  });

  test('clear all removes memories', () async {
    await repository.addMemory(content: 'One', type: MemoryType.general, importance: 1, source: 'test');
    await repository.addMemory(content: 'Two', type: MemoryType.general, importance: 1, source: 'test');

    await repository.clearAllMemories();

    expect(await repository.getAllMemories(), isEmpty);
  });

  test('important memories are sorted by importance', () async {
    await repository.addMemory(content: 'Low', type: MemoryType.general, importance: 2, source: 'test');
    await repository.addMemory(content: 'High', type: MemoryType.personal, importance: 5, source: 'test');
    await repository.addMemory(content: 'Medium', type: MemoryType.task, importance: 4, source: 'test');

    final important = await repository.getImportantMemories();

    expect(important.map((memory) => memory.content), ['High', 'Medium']);
  });

  test('memory command parser recognizes explicit commands', () {
    const parser = MemoryCommandParser();

    final remember = parser.parse('Remember that I prefer Turkish.');
    final forget = parser.parse('Forget that I prefer Turkish.');
    final show = parser.parse('Show my memories');
    final clear = parser.parse('Clear my memories');

    expect(remember.action, MemoryCommandAction.remember);
    expect(remember.type, MemoryType.preference);
    expect(forget.action, MemoryCommandAction.forget);
    expect(show.action, MemoryCommandAction.show);
    expect(clear.action, MemoryCommandAction.clear);
  });

  test('memory context builder returns compact relevant context', () async {
    await repository.addMemory(
      content: 'I prefer Turkish responses',
      type: MemoryType.preference,
      importance: 5,
      source: 'chat',
    );
    await repository.addMemory(
      content: 'My favorite interface style is dark neon blue',
      type: MemoryType.preference,
      importance: 4,
      source: 'chat',
    );

    final context = await MemoryContextBuilder(repository).buildContext('Please respond in Turkish');

    expect(context, contains('Relevant long-term JARVIS memory'));
    expect(context, contains('Turkish'));
    expect(context, isNot(contains('entire memory database')));
  });
}
