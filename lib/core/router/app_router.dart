import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/p_setup/presentation/pages/first_setup_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/setup', builder: (context, state) => const FirstSetupScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});
