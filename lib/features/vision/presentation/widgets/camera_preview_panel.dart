import 'dart:io';

import 'package:flutter/material.dart';

import '../../../widgets/glass_panel.dart';

class CameraPreviewPanel extends StatelessWidget {
  const CameraPreviewPanel({required this.imagePath, super.key});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: imagePath == null
              ? const Center(child: Text('Select camera or gallery to preview an image.'))
              : Image.file(File(imagePath!), fit: BoxFit.cover),
        ),
      ),
    );
  }
}
