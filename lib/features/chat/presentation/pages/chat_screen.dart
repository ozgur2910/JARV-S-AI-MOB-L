import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../ai/domain/models/chat_message.dart';
import '../../../ai/presentation/providers/chat_controller.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';
import '../../../widgets/voice_wave.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).reloadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _controller.text;
    _controller.clear();
    await ref.read(chatControllerProvider.notifier).sendMessage(message);
    if (!_scrollController.hasClients) return;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);

    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 1),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 116),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChatHeader(
              onClear: state.isLoading
                  ? null
                  : ref.read(chatControllerProvider.notifier).clearConversation,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 32,
                child: Column(
                  children: [
                    Expanded(
                      child: state.messages.isEmpty
                          ? const _EmptyChatState()
                          : ListView.separated(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.messages.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) => _MessageBubble(
                                message: state.messages[index],
                              ).animate().fadeIn(duration: 220.ms).slideY(
                                    begin: 0.08,
                                    end: 0,
                                  ),
                            ),
                    ),
                    if (state.isLoading) const _TypingIndicator(),
                    if (state.errorMessage != null)
                      _ErrorBanner(message: state.errorMessage!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _Composer(
              controller: _controller,
              enabled: !state.isLoading,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JARVIS Chat',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
              ),
              Text(
                'Secure Gemini uplink active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neonBlue.withValues(alpha: 0.78),
                    ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Clear conversation',
          onPressed: onClear,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ).animate().fadeIn(duration: 360.ms).slideY(begin: -0.16, end: 0);
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: 0.16),
                  blurRadius: 40,
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.neonBlue, size: 38),
          ),
          const SizedBox(height: 18),
          Text(
            'Mission channel ready',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask JARVIS for planning, code, smart home ideas, or Raspberry Pi automation.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUser
                ? AppTheme.neonBlue.withValues(alpha: 0.17)
                : Colors.white.withValues(alpha: 0.075),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isUser ? 22 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 22),
            ),
            border: Border.all(
              color: isUser
                  ? AppTheme.neonBlue.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? AppTheme.neonBlue : Colors.black)
                    .withValues(alpha: isUser ? 0.12 : 0.24),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 22,
      opacity: 0.06,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 72, child: VoiceWave(active: true)),
          const SizedBox(width: 12),
          Text(
            'JARVIS is thinking',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 0.7,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).shimmer(
          duration: 1400.ms,
          color: AppTheme.neonBlue.withValues(alpha: 0.24),
        );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(14),
        borderRadius: 20,
        opacity: 0.08,
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: 30,
      opacity: 0.1,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (enabled) onSend();
              },
              decoration: const InputDecoration(
                hintText: 'Ask JARVIS anything...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.north_east),
          ),
        ],
      ),
    );
  }
}
