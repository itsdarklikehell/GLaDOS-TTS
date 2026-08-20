#!/bin/bash
# GLaDOS TTS Wrapper
# Resolve the directory this script lives in, so it works regardless of CWD.
TTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPER_BIN="$TTS_DIR/piper"
MODEL="$TTS_DIR/en_US-glados-medium.onnx"

if [ -z "$1" ]; then
  echo "Usage: $0 \"text to speak\""
  exit 1
fi

# Use piper to generate wav, then play it immediately via ffplay
# -nodisp hides the ffplay window, -autoexit closes it when done
echo "$1" | "$PIPER_BIN" --model "$MODEL" --output_raw | ffplay -nodisp -autoexit -ar 22050 -f s16le -
