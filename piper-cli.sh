#!/bin/bash
TTS_DIR="/home/rizzo/.openclaw/workspace/projects/GLaDOS-TTS"
PIPER_BIN="$TTS_DIR/piper"
MODEL="$TTS_DIR/en_US-glados-medium.onnx"

# Piper expects text on stdin and outputs raw PCM to stdout by default.
# We want to save it to a wav file.
# We'll use the --output_file flag if available, or pipe to ffmpeg.

# The plugin provides an output directory. We just need to create a file named "speech.wav"
# because the plugin looks for "speech" prefix.

cat - | "$PIPER_BIN" --model "$MODEL" --output_file "speech.wav"
