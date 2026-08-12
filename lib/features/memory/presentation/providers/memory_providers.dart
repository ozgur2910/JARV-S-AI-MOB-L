import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../data/services/memory_command_parser.dart';
import '../../data/services/memory_context_builder.dart';
import '../../data/services/memory_service.dart';
import '../../domain/repositories/memory_repository.dart';
import 'memory_controller.dart';

final memoryServiceProvider = Provider<MemoryService>((ref) {
  return MemoryService(Hive.box<dynamic>(HiveBoxes.memories));
});

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepositoryImpl(ref.watch(memoryServiceProvider));
});

final memoryCommandParserProvider = Provider<MemoryCommandParser>((ref) {
  return const MemoryCommandParser();
});

final memoryContextBuilderProvider = Provider<MemoryContextBuilder>((ref) {
  return MemoryContextBuilder(ref.watch(memoryRepositoryProvider));
});

final memoryControllerProvider = StateNotifierProvider<MemoryController, MemoryState>((ref) {
  return MemoryController(ref.watch(memoryRepositoryProvider));
});
