#!/bin/bash
# GLaDOS-TTS Install Script
# Installs dependencies and sets up the TTS system.

set -e

TTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_PREFIX="${INSTALL_PREFIX:-/usr/local}"
SYSTEMD_INSTALL=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -p, --prefix PATH    Installation prefix (default: /usr/local)
  -s, --systemd        Install systemd user service
  -h, --help           Show this help message

Examples:
  $(basename "$0")
  $(basename "$0") --prefix ~/.local
  $(basename "$0") --systemd

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
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            ;;
    esac
done

echo "=== GLaDOS-TTS Installer ==="
echo "Install prefix: $INSTALL_PREFIX"
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
    echo "Warning: No supported package manager found. Please install dependencies manually."
    PKG_INSTALL=""
fi

# Install dependencies
echo "Installing dependencies..."
if [ -n "$PKG_INSTALL" ]; then
    $PKG_INSTALL ffmpeg espeak-ng
else
    echo "Please install: ffmpeg, espeak-ng"
fi

# Make scripts executable
echo "Setting permissions..."
chmod +x "$TTS_DIR/speak.sh" "$TTS_DIR/piper-cli.sh" "$TTS_DIR/piper"

# Create symlinks in install prefix
BIN_DIR="$INSTALL_PREFIX/bin"
mkdir -p "$BIN_DIR"

echo "Creating symlinks in $BIN_DIR..."
ln -sf "$TTS_DIR/speak.sh" "$BIN_DIR/glados-speak"
ln -sf "$TTS_DIR/piper-cli.sh" "$BIN_DIR/glados-tts"

echo "Symlinks created:"
echo "  glados-speak  -> $TTS_DIR/speak.sh"
echo "  glados-tts    -> $TTS_DIR/piper-cli.sh"

# Install systemd service if requested
if [ "$SYSTEMD_INSTALL" = true ]; then
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"

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

    echo ""
    echo "Systemd user service installed."
    echo "Enable with: systemctl --user enable glados-tts.service"
    echo "Start with:  systemctl --user start glados-tts.service"
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Quick test:"
echo "  glados-speak \"Hello, Test Subject.\""
echo "  glados-tts \"Hello, Test Subject.\""
