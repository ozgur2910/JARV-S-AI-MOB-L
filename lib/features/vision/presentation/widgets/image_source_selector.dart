import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../widgets/glass_panel.dart';

class ImageSourceSelector extends StatelessWidget {
  const ImageSourceSelector({
    required this.onCameraSelected,
    required this.onGallerySelected,
    super.key,
  });

  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onCameraSelected,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camera'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onGallerySelected,
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.neonBlue),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
            ),
          ),
        ],
      ),
    );
  }
}
