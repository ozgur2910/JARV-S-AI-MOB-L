import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_scaffold.dart';
import '../../data/models/memory_entry.dart';
import '../../domain/models/memory_type.dart';
import '../providers/memory_providers.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(memoryControllerProvider.notifier).loadMemories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryControllerProvider);
    final controller = ref.read(memoryControllerProvider.notifier);
    return JarvisScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Memory Engine',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.12, end: 0),
          const SizedBox(height: 18),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${state.memories.length} memories stored', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: controller.searchMemories,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search long-term memory',
                  ),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: state.memories.isEmpty ? null : () => _confirmClear(context),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear all'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (state.memories.isEmpty)
            const _EmptyMemoryCard()
          else
            ...state.memories.map(
              (memory) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MemoryCard(
                  memory: memory,
                  onEdit: () => _showEditor(context, memory: memory),
                  onDelete: () => controller.deleteMemory(memory.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear memories?'),
        content: const Text('This permanently removes all long-term JARVIS memories.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Clear')),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed ?? false) {
      await ref.read(memoryControllerProvider.notifier).clearAllMemories();
    }
  }

  Future<void> _showEditor(BuildContext context, {MemoryEntry? memory}) async {
    final contentController = TextEditingController(text: memory?.content ?? '');
    var type = memory?.type ?? MemoryType.general;
    var importance = memory?.importance ?? 3;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(memory == null ? 'Add memory' : 'Edit memory'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Memory content'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MemoryType>(
                  value: type,
                  items: MemoryType.values
                      .map((type) => DropdownMenuItem(value: type, child: Text(type.label)))
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => type = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Importance $importance'),
                    Expanded(
                      child: Slider(
                        value: importance.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$importance',
                        onChanged: (value) => setDialogState(() => importance = value.round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (!mounted) {
      contentController.dispose();
      return;
    }
    if (saved ?? false) {
      final controller = ref.read(memoryControllerProvider.notifier);
      if (memory == null) {
        await controller.addMemory(content: contentController.text, type: type, importance: importance);
      } else {
        await controller.updateMemory(memory.copyWith(content: contentController.text, type: type, importance: importance));
      }
    }
    contentController.dispose();
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory, required this.onEdit, required this.onDelete});

  final MemoryEntry memory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(label: Text(memory.type.label), backgroundColor: AppTheme.neonBlue.withValues(alpha: 0.14)),
              const SizedBox(width: 8),
              Text('Importance ${memory.importance}/5', style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
            ],
          ),
          const SizedBox(height: 8),
          Text(memory.content, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Created ${_formatDate(memory.createdAt)} • Source ${memory.source}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  String _formatDate(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class _EmptyMemoryCard extends StatelessWidget {
  const _EmptyMemoryCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        children: [
          const Icon(Icons.psychology_alt_outlined, color: AppTheme.neonBlue, size: 42),
          const SizedBox(height: 12),
          Text('No memories yet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Use Add memory or say “Remember that I prefer Turkish.”', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
