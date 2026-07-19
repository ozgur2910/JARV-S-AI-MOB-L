import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AiOrb extends StatefulWidget {
  const AiOrb({super.key});

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.94 + (_controller.value * 0.12);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Colors.white, AppTheme.neonBlue, AppTheme.deepBlue]),
              boxShadow: [
                BoxShadow(color: AppTheme.neonBlue.withValues(alpha: 0.45), blurRadius: 60, spreadRadius: 8),
                BoxShadow(color: AppTheme.deepBlue.withValues(alpha: 0.35), blurRadius: 100, spreadRadius: 14),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 72, color: Colors.black87),
          ),
        );
      },
    );
  }
}
