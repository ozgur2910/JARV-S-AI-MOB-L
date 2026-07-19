import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({required this.child, this.padding = const EdgeInsets.all(20), super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
