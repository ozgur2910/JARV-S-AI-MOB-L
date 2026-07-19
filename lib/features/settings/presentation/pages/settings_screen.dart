import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GlassPanel(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Gemini API Key'),
                    subtitle: Text('Stored with flutter_secure_storage'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => ref.read(secureStorageServiceProvider).deleteGeminiApiKey(),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove API key'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
