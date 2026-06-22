# JARVIS AI Mobile

Production-ready Flutter starter for a dark, neon-blue, glassmorphism JARVIS AI assistant mobile app.

## Stack

- Flutter stable / Dart 3
- Clean Architecture with feature-first folders
- Riverpod for state management
- GoRouter for navigation
- flutter_secure_storage for the Gemini API key
- Hive for local conversation history and settings

## Getting started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

On first launch, enter a Gemini API key. If a key already exists in secure storage, the splash screen routes directly to Home.

## Structure

```text
lib/
  core/
    router/
    storage/
    theme/
  features/
    splash/
    p_setup/
    home/
    chat/
    settings/
    ai_core/
    voice/
    memory/
    vision/
    documents/
    internet/
    widgets/
```

## Raspberry Pi JARVIS roadmap

The mobile app is prepared as a client for a larger JARVIS ecosystem. For Raspberry Pi 4, build a local assistant service that handles wake-word detection (`Jarvis`), microphone input, speech-to-text, Gemini/OpenAI reasoning, text-to-speech, Home Assistant control, media playback, and app/script launching. The Flutter app can later pair with that service over HTTPS/WebSocket/MQTT.
