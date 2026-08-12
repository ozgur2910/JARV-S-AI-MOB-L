import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/glass_panel.dart';
import '../../domain/models/vision_result.dart';

class VisionResultCard extends StatelessWidget {
  const VisionResultCard({required this.result, this.onRemember, super.key});

  final VisionResult result;
  final VoidCallback? onRemember;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success ? Icons.visibility_outlined : Icons.error_outline,
                color: result.success ? AppTheme.neonBlue : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 10),
              Text(
                result.success ? 'Vision Analysis' : 'Vision Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(result.success ? result.answer : result.errorMessage ?? 'Unknown vision error.'),
          if (result.success && onRemember != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemember,
                icon: const Icon(Icons.psychology_alt_outlined),
                label: const Text('Remember result'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
