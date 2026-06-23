import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_scaffold.dart';

class FirstSetupScreen extends ConsumerStatefulWidget {
  const FirstSetupScreen({super.key});

  @override
  ConsumerState<FirstSetupScreen> createState() => _FirstSetupScreenState();
}

class _FirstSetupScreenState extends ConsumerState<FirstSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(secureStorageServiceProvider).saveGeminiApiKey(_controller.text);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return JarvisScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassPanel(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('First setup', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Enter your Gemini API key. It will be stored securely on this device.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Gemini API Key', prefixIcon: Icon(Icons.key)),
                    validator: (value) => value == null || value.trim().isEmpty ? 'API key is required' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock),
                    label: const Text('Secure and continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
