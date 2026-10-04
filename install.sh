#!/bin/bash
# GLaDOS-TTS Install Script
# Installs dependencies and sets up the TTS system.

set -euo pipefail

TTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"
SYSTEMD_INSTALL=false
DRY_RUN="${DRY_RUN:-false}"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
run() { if [ "$DRY_RUN" = true ]; then log "[DRY-RUN] $*"; else "$@"; fi; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -p, --prefix PATH    Installation prefix (default: /usr/local)
  -s, --systemd        Install systemd user service
  -d, --dry-run        Show what would be done without making changes
  -h, --help           Show this help message

Examples:
  $(basename "$0")
  $(basename "$0") --prefix ~/.local
  $(basename "$0") --systemd
  $(basename "$0") --dry-run

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        -s|--systemd)
            SYSTEMD_INSTALL=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

log "=== GLaDOS-TTS Installer ==="
log "Install prefix: $INSTALL_PREFIX"
log "Dry run: $DRY_RUN"
echo ""

# Detect package manager
PKG_INSTALL=""
if command -v apt-get &>/dev/null; then
    PKG_INSTALL="sudo apt-get install -y"
elif command -v dnf &>/dev/null; then
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman &>/dev/null; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
elif command -v zypper &>/dev/null; then
    PKG_INSTALL="sudo zypper install -y"
else
    log "Warning: No supported package manager found. Please install dependencies manually."
    PKG_INSTALL=""
fi

# Install dependencies
log "Installing dependencies..."
if [ -n "$PKG_INSTALL" ]; then
    run $PKG_INSTALL ffmpeg espeak-ng
else
    log "Please install: ffmpeg, espeak-ng"
fi

# Make scripts executable
log "Setting permissions..."
run chmod +x "$TTS_DIR/speak.sh" "$TTS_DIR/piper-cli.sh" "$TTS_DIR/piper"

# Create symlinks in install prefix
BIN_DIR="$INSTALL_PREFIX/bin"
run mkdir -p "$BIN_DIR"

log "Creating symlinks in $BIN_DIR..."
run ln -sf "$TTS_DIR/speak.sh" "$BIN_DIR/glados-speak"
run ln -sf "$TTS_DIR/piper-cli.sh" "$BIN_DIR/glados-tts"

log "Symlinks created:"
log "  glados-speak  -> $TTS_DIR/speak.sh"
log "  glados-tts    -> $TTS_DIR/piper-cli.sh"

# Install systemd service if requested
if [ "$SYSTEMD_INSTALL" = true ]; then
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    run mkdir -p "$SYSTEMD_DIR"

    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would write systemd service to $SYSTEMD_DIR/glados-tts.service"
    else
        cat > "$SYSTEMD_DIR/glados-tts.service" <<EOF
[Unit]
Description=GLaDOS TTS Service
After=network.target

[Service]
Type=oneshot
ExecStart=$TTS_DIR/speak.sh -q "GLaDOS TTS service loaded."
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
    fi

    log ""
    log "Systemd user service installed."
    log "Enable with: systemctl --user enable glados-tts.service"
    log "Start with:  systemctl --user start glados-tts.service"
fi

log ""
log "=== Installation complete ==="
log ""
log "Quick test:"
log "  glados-speak \"Hello, Test Subject.\""
log "  glados-tts \"Hello, Test Subject.\""
