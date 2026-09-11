# Raspberry Pi 4 JARVIS Assistant Plan

This document describes the production path for a Raspberry Pi 4 companion that works with the Flutter mobile app without changing the mobile Clean Architecture.

## Goals

The Raspberry Pi assistant should:

- Wake when the user says `Jarvis`.
- Listen to Turkish or English speech after wake-word detection.
- Send user requests to the existing AI chat pipeline through a local API bridge.
- Speak responses aloud with text-to-speech.
- Open local Raspberry Pi applications or scripts when explicitly requested.
- Play music through a local media player or a Home Assistant media entity.
- Connect to Home Assistant and control lights, switches, scenes, and automations.

## Recommended Architecture

```text
Wake Word Engine
  ↓
Speech-to-Text
  ↓
Intent Router
  ├── Local App / Script Runner
  ├── Music Controller
  ├── Home Assistant Client
  └── AI Conversation Client
        ↓
      Gemini / Existing AI Repository
        ↓
Text-to-Speech
```

The Raspberry Pi voice layer must not call Gemini directly if the mobile app or a backend gateway already owns the AI repository. Prefer a small local bridge service so all AI requests still flow through the same policy, storage, and error-handling layer.

## Suggested Raspberry Pi Services

| Capability | Recommended option | Notes |
| --- | --- | --- |
| Wake word | OpenWakeWord | Runs locally and supports custom wake words. |
| Speech-to-text | Whisper.cpp or Vosk | Whisper.cpp is more accurate; Vosk is lighter. |
| Text-to-speech | Piper TTS | Fast local TTS with good quality. |
| Home Assistant | REST API or WebSocket API | Use a long-lived access token stored in an `.env` file. |
| Music | MPD, VLC, or Home Assistant media_player | MPD is reliable for local music libraries. |
| Process control | Python subprocess allowlist | Never execute arbitrary AI-generated shell commands. |

## Security Rules

- Store Gemini keys, Home Assistant tokens, and device secrets outside source control.
- Use `.env` files on the Pi and keep them out of Git.
- Use an allowlist for commands such as opening Chromium, launching Spotify, or running known scripts.
- Require confirmation before high-risk actions.
- Do not let LLM responses execute raw shell commands.

## Minimum Python Service Layout

```text
pi_assistant/
  app.py
  config.py
  wake_word.py
  speech_to_text.py
  text_to_speech.py
  intent_router.py
  integrations/
    home_assistant.py
    music.py
    local_apps.py
  requirements.txt
  systemd/jarvis-assistant.service
```

## Home Assistant Flow

1. Create a Home Assistant long-lived access token.
2. Save it on the Raspberry Pi as `HOME_ASSISTANT_TOKEN`.
3. Configure `HOME_ASSISTANT_URL`, for example `http://homeassistant.local:8123`.
4. Map voice intents to Home Assistant service calls:
   - `light.turn_on`
   - `light.turn_off`
   - `scene.turn_on`
   - `automation.trigger`

Example command mapping:

```json
{
  "salon ışığını aç": {
    "domain": "light",
    "service": "turn_on",
    "entity_id": "light.salon"
  }
}
```

## Implementation Phases

### Phase 1: Local Wake and Speech Loop

- Install OpenWakeWord.
- Detect `Jarvis` locally.
- Record the user command.
- Convert speech to text.
- Speak a simple fixed response.

### Phase 2: AI Conversation

- Add an AI bridge endpoint that forwards text to the existing AI repository or backend.
- Return the assistant answer to the Pi.
- Speak the answer with Piper TTS.

### Phase 3: Home Assistant Control

- Add an intent router for home commands.
- Call Home Assistant services through REST or WebSocket.
- Confirm the action verbally, for example `Salon ışığı açıldı.`

### Phase 4: Local Apps and Music

- Add an allowlisted local command runner.
- Add MPD or VLC integration.
- Add commands such as:
  - `Jarvis, müzik aç.`
  - `Jarvis, Chromium'u aç.`
  - `Jarvis, salon ışığını kapat.`

### Phase 5: Mobile Companion Integration

- Show Raspberry Pi connection status in the Flutter settings screen.
- Let the mobile app configure Pi host, language, speech speed, and Home Assistant room mappings.
- Sync conversation history if required.

## Production Checklist

- [ ] Run the Pi service as a systemd service.
- [ ] Add automatic restart on failure.
- [ ] Add structured logs.
- [ ] Add wake-word false-positive tuning.
- [ ] Add Turkish language defaults.
- [ ] Add Home Assistant entity discovery.
- [ ] Add a command allowlist.
- [ ] Add tests for intent routing.
