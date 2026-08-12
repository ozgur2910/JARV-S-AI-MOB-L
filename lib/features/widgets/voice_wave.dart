import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class VoiceWave extends StatefulWidget {
  const VoiceWave({this.active = false, super.key});

  final bool active;

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _VoiceWavePainter(_controller.value, widget.active),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _VoiceWavePainter extends CustomPainter {
  const _VoiceWavePainter(this.progress, this.active);

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = AppTheme.neonBlue.withValues(alpha: active ? 0.95 : 0.35);

    const bars = 21;
    final gap = size.width / bars;
    for (var i = 0; i < bars; i++) {
      final phase = progress * math.pi * 2 + i * 0.55;
      final normalized = active ? (math.sin(phase).abs() * 0.75 + 0.25) : 0.18;
      final height = normalized * size.height;
      final x = gap * i + gap / 2;
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}
