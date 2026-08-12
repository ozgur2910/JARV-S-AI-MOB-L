import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../ai/domain/models/chat_message.dart';
import 'glass_panel.dart';

class ConversationCard extends StatelessWidget {
  const ConversationCard({required this.lastMessage, super.key});

  final ChatMessage? lastMessage;

  @override
  Widget build(BuildContext context) {
    final message = lastMessage;
    return GlassPanel(
      borderRadius: 30,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => context.go('/chat'),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.neonBlue.withValues(alpha: 0.14),
                  border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.forum_outlined, color: AppTheme.neonBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversation Preview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message?.content ?? 'No messages yet. Start a mission briefing with JARVIS.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.12, end: 0);
  }
}
