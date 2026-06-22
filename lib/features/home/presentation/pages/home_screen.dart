import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';
import '../providers/assistant_status_provider.dart';
import '../widgets/ai_orb.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(assistantStatusProvider);
    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AiOrb(),
            const SizedBox(height: 36),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(status.label, key: ValueKey(status), style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 48),
            FilledButton(
              style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(28)),
              onPressed: () => ref.read(assistantStatusProvider.notifier).state = AssistantStatus.listening,
              child: const Icon(Icons.mic, size: 42),
            ),
          ],
        ),
      ),
    );
  }
}
