# Vision

Sprint 6 adds the JARVIS Vision Engine. Images are selected only after explicit user action from camera or gallery, validated locally, resized/compressed by `image_picker`, and analyzed through `VisionController → VisionRepository → VisionService → existing AI Repository → Gemini`.
