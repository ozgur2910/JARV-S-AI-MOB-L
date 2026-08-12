import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/assistant_status_provider.dart';
import '../../../home/presentation/widgets/ai_orb.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';
import '../providers/vision_controller.dart';
import '../providers/vision_providers.dart';
import '../widgets/camera_preview_panel.dart';
import '../widgets/image_source_selector.dart';
import '../widgets/vision_result_card.dart';

class VisionScreen extends ConsumerStatefulWidget {
  const VisionScreen({super.key});

  @override
  ConsumerState<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends ConsumerState<VisionScreen> {
  final _questionController = TextEditingController(text: 'What do you see?');

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visionControllerProvider);
    final controller = ref.read(visionControllerProvider.notifier);
    final isAnalyzing = state.mode == VisionMode.analyzing;
    return JarvisScaffold(
      bottomNavigationBar: const JarvisBottomNav(currentIndex: 2),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 116),
        children: [
          Text(
            'Vision Engine',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.12, end: 0),
          const SizedBox(height: 6),
          Text(
            'Analyze a camera capture or gallery image only after explicit selection.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          Center(
            child: AiOrb(
              status: isAnalyzing ? AssistantStatus.thinking : AssistantStatus.ready,
            ),
          ),
          const SizedBox(height: 20),
          ImageSourceSelector(
            onCameraSelected: controller.pickFromCamera,
            onGallerySelected: controller.pickFromGallery,
          ),
          const SizedBox(height: 16),
          CameraPreviewPanel(imagePath: state.selectedImage?.path),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.help_outline),
                    hintText: 'Ask JARVIS about this image',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.selectedImage == null || isAnalyzing ? null : controller.retake,
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.neonBlue),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: state.selectedImage == null || isAnalyzing
                            ? null
                            : () => controller.analyzeSelectedImage(_questionController.text),
                        icon: isAnalyzing
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(isAnalyzing ? 'Analyzing' : 'Analyze'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            GlassPanel(
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
            ),
          ],
          if (state.result != null) ...[
            const SizedBox(height: 16),
            VisionResultCard(
              result: state.result!,
              onRemember: state.result!.success
                  ? () => controller.rememberLastResult()
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
