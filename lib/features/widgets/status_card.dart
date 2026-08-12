import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../home/presentation/providers/assistant_status_provider.dart';
import 'glass_panel.dart';
import 'voice_wave.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({required this.status, super.key});

  final AssistantStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == AssistantStatus.listening;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status == AssistantStatus.error
                  ? Theme.of(context).colorScheme.error
                  : AppTheme.neonBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withValues(alpha: isActive ? 0.65 : 0.25),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.2, 1.2),
                duration: 900.ms,
              ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: 250.ms,
              child: Column(
                key: ValueKey(status),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle(status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (isActive) SizedBox(width: 92, child: VoiceWave(active: isActive)),
        ],
      ),
    );
  }

  String _subtitle(AssistantStatus status) {
    return switch (status) {
      AssistantStatus.ready => 'Systems online',
      AssistantStatus.listening => 'Voice input active',
      AssistantStatus.thinking => 'Neural engine processing',
      AssistantStatus.speaking => 'Audio response streaming',
      AssistantStatus.error => 'Attention required',
    };
  }
}
