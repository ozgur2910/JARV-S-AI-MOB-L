import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../voice/presentation/providers/voice_controller.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _haptics = true;
  bool _secureMemory = true;

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceControllerProvider);
    final voiceController = ref.read(voiceControllerProvider.notifier);
    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 3),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 116),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.14, end: 0),
          const SizedBox(height: 6),
          Text(
            'Configure the JARVIS mobile interface',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'AI Core',
            children: [
              _SettingsTile(
                icon: Icons.security,
                title: 'Gemini API Key',
                subtitle: 'Encrypted using secure device storage',
                trailing: FilledButton.tonalIcon(
                  onPressed: () {
                    ref.read(secureStorageServiceProvider).deleteGeminiApiKey();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gemini API key removed')),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
              ),
              _SettingsTile(
                icon: Icons.psychology_alt_outlined,
                title: 'Memory Engine',
                subtitle: 'Manage long-term JARVIS memories',
                trailing: IconButton.filledTonal(
                  onPressed: () => context.push('/memory'),
                  icon: const Icon(Icons.chevron_right),
                ),
              ),
              _SettingsTile(
                icon: Icons.memory,
                title: 'Secure Memory',
                subtitle: 'Keep local conversation context in Hive',
                trailing: Switch(
                  value: _secureMemory,
                  onChanged: (value) => setState(() => _secureMemory = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SettingsSection(
            title: 'Voice Interface',
            children: [
              _SettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: voiceState.language,
                trailing: DropdownButton<String>(
                  value: voiceState.language,
                  borderRadius: BorderRadius.circular(18),
                  dropdownColor: AppTheme.surface,
                  items: const [
                    DropdownMenuItem(value: 'en-US', child: Text('English')),
                    DropdownMenuItem(value: 'tr-TR', child: Text('Türkçe')),
                  ],
                  onChanged: (value) {
                    if (value != null) voiceController.updateLanguage(value);
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.record_voice_over,
                title: 'Auto Listen',
                subtitle: 'Automatically return to listening after speaking',
                trailing: Switch(
                  value: voiceState.autoListen,
                  onChanged: voiceController.updateAutoListen,
                ),
              ),
              _SettingsTile(
                icon: Icons.speed,
                title: 'Speech Rate',
                subtitle: voiceState.speechRate.toStringAsFixed(2),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    value: voiceState.speechRate,
                    min: 0.2,
                    max: 0.9,
                    onChanged: voiceController.updateSpeechRate,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.graphic_eq,
                title: 'Pitch',
                subtitle: voiceState.pitch.toStringAsFixed(2),
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    value: voiceState.pitch,
                    min: 0.6,
                    max: 1.6,
                    onChanged: voiceController.updatePitch,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Subtle response feedback for mission actions',
                trailing: Switch(
                  value: _haptics,
                  onChanged: (value) => setState(() => _haptics = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _SystemCard(),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 30,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.neonBlue,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.08, end: 0);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, color: AppTheme.neonBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderRadius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_outlined, color: AppTheme.neonBlue),
              const SizedBox(width: 10),
              Text(
                'Companion Roadmap',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Raspberry Pi voice wake, Home Assistant lights, media control, and local app launching can connect here through future modules.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}
