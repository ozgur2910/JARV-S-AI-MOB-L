import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'glass_panel.dart';

class JarvisBottomNav extends StatelessWidget {
  const JarvisBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return JarvisBottomNavigation(currentIndex: currentIndex);
  }
}

class JarvisBottomNavigation extends StatelessWidget {
  const JarvisBottomNavigation({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        borderRadius: 32,
        opacity: 0.1,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.blur_circular,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              selected: currentIndex == 1,
              onTap: () => context.go('/chat'),
            ),
            _NavItem(
              icon: Icons.visibility_outlined,
              label: 'Vision',
              selected: currentIndex == 2,
              onTap: () => context.go('/vision'),
            ),
            _NavItem(
              icon: Icons.tune,
              label: 'Settings',
              selected: currentIndex == 3,
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.neonBlue.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppTheme.neonBlue.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppTheme.neonBlue : Colors.white54,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : Colors.white54,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
