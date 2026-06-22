import 'package:flutter/material.dart';

import '../../../widgets/glass_panel.dart';
import '../../../widgets/jarvis_bottom_nav.dart';
import '../../../widgets/jarvis_scaffold.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const JarvisScaffold(
      bottomNavigationBar: JarvisBottomNav(currentIndex: 1),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chat', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(child: GlassPanel(child: Center(child: Text('Conversation history will appear here.')))),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(hintText: 'Ask JARVIS anything...', suffixIcon: Icon(Icons.send))),
          ],
        ),
      ),
    );
  }
}
