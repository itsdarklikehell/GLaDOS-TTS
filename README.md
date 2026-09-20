# GLaDOS TTS
A local Text-to-Speech implementation using the GLaDOS voice model via Piper.

## Overview
This project provides a wrapper around the Piper TTS engine to allow for easy generation of audio in the voice of GLaDOS from Portal. It is designed for use within the OpenClaw workspace for voice feedback and character-driven interactions.

## Components
- **TTS Engine**: [Piper](https://github.com/rhasspy/piper)
- **Model**: GLaDOS medium (ONNX)
- **Wrapper**: `speak.sh` - A simple bash script to pipe text to Piper and play it via `ffplay`.

## Installation & Usage
The project is self-contained within its directory. All dependencies are shipped as binaries or model files.

### Prerequisites
- Linux x86_64 (Piper binary included, compiled for this platform)
- `ffmpeg` (provides `ffplay` for audio playback) — `sudo apt install ffmpeg`
- Python 3.9+ with `piper-tts` package: `pip install piper-tts`

### Setup
No build step required. The Piper binary and GLaDOS ONNX model are included:

```bash
cd GLaDOS-TTS
chmod +x speak.sh piper-cli.sh piper
```

Verify Piper works:
```bash
echo "test" | ./piper --model en_US-glados-medium.onnx --output_file /tmp/test.wav
```

### Basic Usage
To speak a phrase through your speakers:
```bash
./speak.sh "Hello, Test Subject."
```

To generate a WAV file instead:
```bash
./piper-cli.sh <<< "Hello, Test Subject."
# Outputs speech.wav in the project directory
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
