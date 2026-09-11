import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/jarvis_scaffold.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 900), _route);
  }

  Future<void> _route() async {
    final key = await ref.read(secureStorageServiceProvider).readGeminiApiKey();
    if (!mounted) return;
    context.go(key == null || key.isEmpty ? '/setup' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const JarvisScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.neonBlue, size: 84),
            SizedBox(height: 24),
            Text('JARVIS AI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
