import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class JarvisScaffold extends StatelessWidget {
  const JarvisScaffold({
    required this.child,
    this.bottomNavigationBar,
    super.key,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppTheme.background),
        child: Stack(
          children: [
            const Positioned.fill(child: _JarvisBackground()),
            SafeArea(child: child),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _JarvisBackground extends StatelessWidget {
  const _JarvisBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _JarvisBackgroundPainter(),
    );
  }
}

class _JarvisBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = AppTheme.neonBlue.withValues(alpha: 0.06);

    const spacing = 44.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height * 0.18, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + size.width * 0.08), paint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.neonBlue.withValues(alpha: 0.17),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.18),
        radius: size.width * 0.78,
      ));
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
