import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
    this.opacity = 0.08,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppTheme.neonBlue.withValues(alpha: 0.22),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity + 0.04),
                Colors.white.withValues(alpha: opacity * 0.35),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withValues(alpha: 0.12),
                blurRadius: 42,
                spreadRadius: -10,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
