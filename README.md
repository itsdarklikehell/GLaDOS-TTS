# GLaDOS TTS

[![CI](https://github.com/itsdarklikehell/GLaDOS-TTS/actions/workflows/ci.yml/badge.svg)](https://github.com/itsdarklikehell/GLaDOS-TTS/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/itsdarklikehell/GLaDOS-TTS)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

A local Text-to-Speech implementation using the GLaDOS voice model via Piper. Designed for use within the OpenClaw workspace for voice feedback and character-driven interactions.

## Overview

This project wraps the [Piper](https://github.com/rhasspy/piper) TTS engine to generate audio in the voice of GLaDOS from Portal. It includes a pre-built Piper binary, the GLaDOS ONNX voice model, and espeak-ng data for phonemization — everything needed to run offline.

## Components

- **TTS Engine**: [Piper](https://github.com/rhasspy/piper) — fast, local neural TTS
- **Voice Model**: GLaDOS medium quality (ONNX format, ~63 MB)
- **Phonemizer**: espeak-ng (included binary + data)
- **Audio Playback**: ffplay (from ffmpeg)
- **Wrappers**: `speak.sh` (play audio) and `piper-cli.sh` (save to WAV)

## Requirements

- **OS**: Linux x86_64 (Piper binary included, compiled for this platform)
- **ffmpeg**: for `ffplay` audio playback — `sudo apt install ffmpeg`
- **Python 3.9+** (optional): `pip install piper-tts` for the Python API

## Installation

### Quick Start

```bash
git clone https://github.com/itsdarklikehell/GLaDOS-TTS.git
cd GLaDOS-TTS
chmod +x speak.sh piper-cli.sh piper
```

### Install Script (Recommended)

The install script handles dependencies, permissions, and optional systemd service setup:

```bash
./install.sh              # Basic install (symlinks to /usr/local/bin)
./install.sh --systemd    # Also install systemd user service
./install.sh --prefix ~/.local  # Custom install prefix
```

This creates two symlinks:
- `glados-speak` → `speak.sh` (play audio through speakers)
- `glados-tts` → `piper-cli.sh` (save audio to WAV file)

### Manual Dependencies

If you prefer to install dependencies manually:

```bash
# Debian/Ubuntu
sudo apt install ffmpeg espeak-ng

# Fedora
sudo dnf install ffmpeg espeak-ng

# Arch
sudo pacman -S ffmpeg espeak-ng
```

## Usage

### Speak (Play Audio)

```bash
# Basic usage
./speak.sh "Hello, Test Subject."

# Save to file instead of playing
./speak.sh -o /tmp/glados.wav "Hello, Test Subject."

# Adjust volume (0.0 to 1.0)
./speak.sh -v 0.5 "Hello, Test Subject."

# Suppress log messages
./speak.sh -q "Hello, Test Subject."

# Pipe text in
echo "Hello, Test Subject." | ./speak.sh -q
```

### Generate WAV File

```bash
# Basic usage (outputs speech.wav in current directory)
./piper-cli.sh "Hello, Test Subject."

# Specify output file
./piper-cli.sh -o /tmp/test.wav "Hello, Test Subject."

# Force overwrite without prompting
./piper-cli.sh -f "Hello, Test Subject."

# Read from stdin
echo "Hello, Test Subject." | ./piper-cli.sh
```

### Direct Piper Usage

```bash
# Generate WAV
echo "test" | ./piper --model en_US-glados-medium.onnx --output_file /tmp/test.wav

# Stream raw audio
echo "test" | ./piper --model en_US-glados-medium.onnx --output_raw | ffplay -nodisp -autoexit -ar 22050 -f s16le -

# Adjust voice parameters
echo "test" | ./piper --model en_US-glados-medium.onnx \
  --noise_scale 0.667 \
  --length_scale 1.0 \
  --noise_w 0.8 \
  --sentence_silence 0.2 \
  --output_file /tmp/test.wav
```

## Voice Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--noise_scale` | 0.667 | Generator noise (higher = more variation) |
| `--length_scale` | 1.0 | Phoneme length (higher = slower speech) |
| `--noise_w` | 0.8 | Phoneme width noise |
| `--sentence_silence` | 0.2 | Seconds of silence after each sentence |

## Systemd Service

To run a test message on boot:

```bash
./install.sh --systemd
systemctl --user enable glados-tts.service
systemctl --user start glados-tts.service
```

## Troubleshooting

- **`ffplay` option error** (`Failed to set value '1' for option 'ac'`): Fixed in `speak.sh` — playback uses `--output_raw` piped to `ffplay -ar 22050 -f s16le`.
- **JSON parse error** (`json.exception.parse_error`): Caused by corrupted `.onnx.json` (HTML from a failed download). The bundled model config is valid.
- **No audio output**: Check that your audio device is configured and `ffplay` can play audio: `ffplay -f s16le -ar 22050 -ac 1 /tmp/test.wav`.
- **Permission denied**: Ensure scripts are executable: `chmod +x speak.sh piper-cli.sh piper`.

## Project Structure

```
.
├── speak.sh              # Play audio through speakers
├── piper-cli.sh          # Save audio to WAV file
├── install.sh            # Installation script
├── piper                 # Piper TTS binary
├── piper_phonemize       # Phonemization binary
├── en_US-glados-medium.onnx      # GLaDOS voice model
├── en_US-glados-medium.onnx.json # Model configuration
├── espeak-ng             # espeak-ng binary
├── espeak-ng-data/       # espeak-ng language data
├── libpiper_phonemize.so # Phonemization library
├── libonnxruntime.so    # ONNX Runtime library
├── libespeak-ng.so       # espeak-ng library
└── libtashkeel_model.ort # Arabic diacritization model
```

## License

[MIT](LICENSE)
