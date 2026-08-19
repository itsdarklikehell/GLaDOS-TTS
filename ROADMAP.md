# Roadmap - GLaDOS TTS

## Phase 1: Core Functionality (Current)
- Stabilize the TTS pipeline (Piper + GLaDOS model).
- Ensure zero-latency-like playback via `ffplay`.
- Basic shell wrapper for easy invocation.

## Phase 2: Integration & Polish
- Integration with the main agent's voice output (via OpenClaw skills).
- Adding "emotional" markers or SSML-like control (if supported by the model).
- Integration with home automation triggers (inspired by the GLaDOS Respeaker project).

## Phase 3: Advanced Features
- Implement a "personality" layer that pre-processes text to sound more like GLaDOS (sarcasm, passive-aggression) before sending it to TTS.
- Support for multiple GLaDOS voice variants (if available).
- Low-resource deployment (e.g., on ESP32/Raspberry Pi satellites).
