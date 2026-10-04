#!/bin/bash
# Piper CLI wrapper for GLaDOS TTS
# Resolve the directory this script lives in, so it works regardless of CWD.
set -euo pipefail

TTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPER_BIN="$TTS_DIR/piper"
MODEL="$TTS_DIR/en_US-glados-medium.onnx"

# Defaults
OUTPUT_FILE="speech.wav"
FORCE=false
QUIET=false

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [TEXT]

If TEXT is provided, it is used as input. Otherwise, stdin is read.

Options:
  -o, --output FILE    Output WAV file (default: speech.wav)
  -f, --force          Overwrite output file without asking
  -q, --quiet         Suppress piper log messages
  -h, --help           Show this help message

Examples:
  $(basename "$0") "Hello, Test Subject."
  echo "Hello" | $(basename "$0")
  $(basename "$0") -o /tmp/test.wav "Hello, Test Subject."
  $(basename "$0") -f "Hello, Test Subject."

EOF
    exit 0
}

# Parse arguments
TEXT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            ;;
        *)
            TEXT="$1"
            shift
            ;;
    esac
done

# Check piper binary exists
if [ ! -x "$PIPER_BIN" ]; then
    log "Error: piper binary not found at $PIPER_BIN"
    exit 1
fi

# Check model exists
if [ ! -f "$MODEL" ]; then
    log "Error: model not found at $MODEL"
    exit 1
fi

# Check if output file exists
if [ -f "$OUTPUT_FILE" ] && [ "$FORCE" = false ]; then
    read -p "File '$OUTPUT_FILE' exists. Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Aborted."
        exit 1
    fi
fi

# Build piper command
PIPER_ARGS=(--model "$MODEL")
if [ "$QUIET" = true ]; then
    PIPER_ARGS+=(--quiet)
fi

# Run piper
if [ -n "$TEXT" ]; then
    echo "$TEXT" | "$PIPER_BIN" "${PIPER_ARGS[@]}" --output_file "$OUTPUT_FILE"
else
    "$PIPER_BIN" "${PIPER_ARGS[@]}" --output_file "$OUTPUT_FILE"
fi

EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    log "Error: piper failed with exit code $EXIT_CODE"
    exit $EXIT_CODE
fi

if [ "$QUIET" = false ]; then
    echo "Audio saved to: $OUTPUT_FILE"
fi
