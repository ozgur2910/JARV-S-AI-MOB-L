import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JarvisBottomNav extends StatelessWidget {
  const JarvisBottomNav({required this.currentIndex, super.key});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/chat');
          case 2:
            context.go('/settings');
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.blur_circular), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
      ],
    );
  }
}
