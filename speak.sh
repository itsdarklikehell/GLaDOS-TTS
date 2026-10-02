#!/bin/bash
# GLaDOS TTS Wrapper
# Resolve the directory this script lives in, so it works regardless of CWD.
TTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPER_BIN="$TTS_DIR/piper"
MODEL="$TTS_DIR/en_US-glados-medium.onnx"

# Defaults
OUTPUT_FILE=""
VOLUME=""
QUIET=false
EXTRA_ARGS=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] "text to speak"

Options:
  -o, --output FILE    Save audio to FILE instead of playing
  -v, --volume NUM     Set playback volume (0.0-1.0, default: 1.0)
  -q, --quiet         Suppress piper log messages
  -h, --help           Show this help message

Examples:
  $(basename "$0") "Hello, Test Subject."
  $(basename "$0") -o /tmp/glados.wav "Hello, Test Subject."
  $(basename "$0") -v 0.5 "Hello, Test Subject."
  echo "Hello" | $(basename "$0") -q

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
        -v|--volume)
            VOLUME="$2"
            shift 2
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

if [ -z "$TEXT" ] && [ -t 0 ]; then
    echo "Error: No text provided." >&2
    usage
fi

# Build piper command
PIPER_ARGS=(--model "$MODEL")
if [ "$QUIET" = true ]; then
    PIPER_ARGS+=(--quiet)
fi

# Check piper binary exists
if [ ! -x "$PIPER_BIN" ]; then
    echo "Error: piper binary not found at $PIPER_BIN" >&2
    exit 1
fi

# Check model exists
if [ ! -f "$MODEL" ]; then
    echo "Error: model not found at $MODEL" >&2
    exit 1
fi

if [ -n "$OUTPUT_FILE" ]; then
    # Save to file
    if [ "$QUIET" = true ]; then
        echo "$TEXT" | "$PIPER_BIN" "${PIPER_ARGS[@]}" --output_file "$OUTPUT_FILE"
    else
        echo "$TEXT" | "$PIPER_BIN" "${PIPER_ARGS[@]}" --output_file "$OUTPUT_FILE"
    fi
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error: piper failed with exit code $EXIT_CODE" >&2
        exit $EXIT_CODE
    fi
    if [ "$QUIET" = false ]; then
        echo "Audio saved to: $OUTPUT_FILE"
    fi
else
    # Play via ffplay
    if ! command -v ffplay &>/dev/null; then
        echo "Error: ffplay not found. Install ffmpeg: sudo apt install ffmpeg" >&2
        exit 1
    fi

    FFPLAY_ARGS=(-nodisp -autoexit -ar 22050 -f s16le -)
    if [ -n "$VOLUME" ]; then
        FFPLAY_ARGS=(-nodisp -autoexit -ar 22050 -f s16le -volume "$VOLUME" -)
    fi

    echo "$TEXT" | "$PIPER_BIN" "${PIPER_ARGS[@]}" --output_raw | ffplay "${FFPLAY_ARGS[@]}"
    EXIT_CODE=${PIPESTATUS[0]}
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error: piper failed with exit code $EXIT_CODE" >&2
        exit $EXIT_CODE
    fi
fi
