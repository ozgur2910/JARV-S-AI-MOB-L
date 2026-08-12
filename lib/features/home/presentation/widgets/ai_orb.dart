import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/assistant_status_provider.dart';

class AiOrb extends StatefulWidget {
  const AiOrb({required this.status, super.key});

  final AssistantStatus status;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with TickerProviderStateMixin {
  late final AnimationController _breathingController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat();

  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 220,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breathingController,
          _pulseController,
          _rotationController,
        ]),
        builder: (context, child) {
          final breathing = 0.97 + _breathingController.value * 0.06;
          final rotation = widget.status == AssistantStatus.thinking
              ? _rotationController.value * math.pi * 2
              : _rotationController.value * math.pi * 0.35;
          final speakingGlow = widget.status == AssistantStatus.speaking ? 1.0 : 0.0;

          return Transform.scale(
            scale: breathing,
            child: CustomPaint(
              painter: _AiOrbPainter(
                pulse: _pulseController.value,
                rotation: rotation,
                speakingGlow: speakingGlow,
                isListening: widget.status == AssistantStatus.listening,
                hasError: widget.status == AssistantStatus.error,
              ),
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: widget.status == AssistantStatus.error
                          ? const [Color(0xFFFF8AA0), Color(0xFFFF355E), Color(0xFF27020A)]
                          : const [Colors.white, AppTheme.neonBlue, Color(0xFF032B43)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.status == AssistantStatus.error
                                ? Theme.of(context).colorScheme.error
                                : AppTheme.neonBlue)
                            .withValues(alpha: 0.42 + speakingGlow * 0.24),
                        blurRadius: 46,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.black87,
                    size: 38,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiOrbPainter extends CustomPainter {
  const _AiOrbPainter({
    required this.pulse,
    required this.rotation,
    required this.speakingGlow,
    required this.isListening,
    required this.hasError,
  });

  final double pulse;
  final double rotation;
  final double speakingGlow;
  final bool isListening;
  final bool hasError;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final accent = hasError ? const Color(0xFFFF4D6D) : AppTheme.neonBlue;
    final outerGlow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32)
      ..color = accent.withValues(alpha: 0.2 + speakingGlow * 0.18);
    canvas.drawCircle(center, 92 + pulse * 14, outerGlow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = SweepGradient(
        transform: GradientRotation(rotation),
        colors: [
          Colors.transparent,
          accent.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.9),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);

    for (final radius in [106.0, 84.0, 64.0]) {
      canvas.drawCircle(center, radius, ringPaint);
    }

    final tickPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: isListening ? 0.85 : 0.46);
    for (var i = 0; i < 42; i++) {
      final angle = rotation + (math.pi * 2 / 42) * i;
      final startRadius = i.isEven ? 98.0 : 102.0;
      final endRadius = startRadius + (i % 4 == 0 ? 10 : 5);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * startRadius,
        center + Offset(math.cos(angle), math.sin(angle)) * endRadius,
        tickPaint,
      );
    }

    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: (1 - pulse) * 0.35);
    canvas.drawCircle(center, 74 + pulse * 36, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _AiOrbPainter oldDelegate) => true;
}
