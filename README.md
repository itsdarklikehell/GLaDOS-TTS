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
If you encounter a `json.exception.parse_error`, it is likely that the `.onnx.json` file is corrupted or contains HTML (from a failed download). Ensure you have the actual JSON configuration file for the model.
