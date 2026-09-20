# GLaDOS TTS
A local Text-to-Speech implementation using the GLaDOS voice model via Piper.

## Overview
This project provides a wrapper around the Piper TTS engine to allow for easy generation of audio in the voice of GLaDOS from Portal. It is designed for use within the OpenClaw workspace for voice feedback and character-driven interactions.

## Components
- **TTS Engine**: [Piper](https://github.com/rhasspy/piper)
- **Model**: GLaDOS medium (ONNX)
- **Wrapper**: `speak.sh` - A simple bash script to pipe text to Piper and play it via `ffplay`.

## Installation & Usage
The project is intended to be self-contained within its directory.

### Basic Usage
To speak a phrase:
```bash
./speak.sh "Hello, Test Subject."
```

## Dependencies
- `piper` (binary)
- `ffplay` (from ffmpeg)
- `espeak-ng` (for phonemization)
- GLaDOS ONNX model and JSON configuration

## Troubleshooting
- **`ffplay` option error** (`Failed to set value '1' for option 'ac'`): fixed in `speak.sh` — playback uses `--output_raw` piped to `ffplay -ar 22050 -f s16le`. If you still hit it, ensure `ffplay` (from ffmpeg) is installed.
- **JSON parse error** (`json.exception.parse_error`): this was caused by a corrupted `.onnx.json` (HTML from a failed download). The bundled model config is now valid; if you still see it, re-download `en_US-glados-medium.onnx.json`.

---

## 🎥 Gource Visualization

De ontwikkelhistorie van dit project in een film:

<video src="https://raw.githubusercontent.com/itsdarklikehell/GLaDOS-TTS/main/gource.mp4" controls width="100%"></video>
