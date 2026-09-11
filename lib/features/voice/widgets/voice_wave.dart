import 'package:flutter/material.dart';

import '../../widgets/voice_wave.dart' as shared;

class VoiceWave extends StatelessWidget {
  const VoiceWave({super.key});

  @override
  Widget build(BuildContext context) {
    return const shared.VoiceWave(active: true);
  }
}
