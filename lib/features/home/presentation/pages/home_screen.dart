import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../ai/presentation/providers/chat_controller.dart';
import '../../../widgets/conversation_card.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';
import '../../../voice/domain/models/voice_state.dart';
import '../../../voice/presentation/providers/voice_controller.dart';
import '../../../voice/widgets/voice_wave.dart';
import '../../../widgets/status_card.dart';
import '../providers/assistant_status_provider.dart';
import '../widgets/ai_orb.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceControllerProvider.notifier).startAutoListening();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceControllerProvider);
    final status = _statusFromVoiceMode(voiceState.mode);
    final chatState = ref.watch(chatControllerProvider);

    ref.listen(voiceControllerProvider, (previous, next) {
      if (next.permissionDenied && previous?.permissionDenied != true) {
        _showMicrophonePermissionDialog(context);
      }
    });
    final lastMessage = chatState.messages.lastOrNull;
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 760;

    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 0),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, compact ? 108 : 116),
        child: Column(
          children: [
            _HomeHeader(time: _formatTime(_now)),
            SizedBox(height: compact ? 22 : 34),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AiOrb(status: status)
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(begin: const Offset(0.9, 0.9)),
                          SizedBox(height: compact ? 18 : 28),
                          StatusCard(status: status),
                          if (voiceState.mode == VoiceMode.listening) ...[
                            const SizedBox(height: 12),
                            const VoiceWave(),
                          ],
                          if (voiceState.transcript.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              voiceState.transcript,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                          SizedBox(height: compact ? 16 : 24),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.mic,
                                  label: 'Listen',
                                  onTap: () => ref
                                      .read(voiceControllerProvider.notifier)
                                      .startListening(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.psychology_alt_outlined,
                                  label: 'Think',
                                  onTap: () => ref
                                      .read(assistantStatusProvider.notifier)
                                      .state = AssistantStatus.thinking,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.graphic_eq,
                                  label: 'Speak',
                                  onTap: () => ref
                                      .read(assistantStatusProvider.notifier)
                                      .state = AssistantStatus.speaking,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: compact ? 16 : 24),
                          ConversationCard(lastMessage: lastMessage),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  AssistantStatus _statusFromVoiceMode(VoiceMode mode) {
    return switch (mode) {
      VoiceMode.idle => AssistantStatus.ready,
      VoiceMode.listening => AssistantStatus.listening,
      VoiceMode.thinking => AssistantStatus.thinking,
      VoiceMode.speaking => AssistantStatus.speaking,
      VoiceMode.error => AssistantStatus.error,
    };
  }

  Future<void> _showMicrophonePermissionDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Microphone permission needed'),
          content: const Text(
            'JARVIS needs microphone access to listen for your voice commands.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(voiceControllerProvider.notifier).retryPermission();
              },
              child: const Text('Retry'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(voiceControllerProvider.notifier).openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JARVIS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
              ),
              Text(
                'Mark XLII interface online',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neonBlue.withValues(alpha: 0.85),
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ).animate().fadeIn(duration: 420.ms).slideY(begin: -0.18, end: 0);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.neonBlue.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.28)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.neonBlue),
            const SizedBox(height: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
