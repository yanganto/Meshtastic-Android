#!/usr/bin/env bash
# Install Meshtastic Android APK on device/emulator

set -euo pipefail

help() {
  cat << 'EOF'
Install Meshtastic Android APK on device/emulator

Usage: install-apk [FLAVOR] [TYPE]

FLAVOR:
  google    - Google Play flavor (default)
  fdroid    - F-Droid flavor

TYPE:
  debug     - Debug build (default)
  release   - Release build

Examples:
  install-apk                  # Install google debug
  install-apk fdroid           # Install fdroid debug
  install-apk google release   # Install google release

Requirements:
  - Device or emulator must be connected via ADB
  - APK must be built first (use build-apk command)

Tip:
  Use: adb devices (to list connected devices)
       adb logcat (to view app logs)
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  help
  exit 0
fi

FLAVOR="${1:-google}"
TYPE="${2:-debug}"

# Validate inputs
case "$FLAVOR" in
  google|fdroid) ;;
  *)
    echo "Error: Unknown flavor '$FLAVOR'" >&2
    help
    exit 1
    ;;
esac

case "$TYPE" in
  debug|release) ;;
  *)
    echo "Error: Unknown type '$TYPE'" >&2
    help
    exit 1
    ;;
esac

# Check for connected devices
if ! adb devices | grep -qE "[a-zA-Z0-9_:-]+\s+device"; then
  echo "Error: No Android device or emulator found!" >&2
  echo ""
  echo "Connect a device or start an emulator, then try again."
  adb devices
  exit 1
fi

# Install APK variant
INSTALL_TASK="install$(printf '%s\n' "$FLAVOR" | sed 's/^./\U&/')$(printf '%s\n' "$TYPE" | sed 's/^./\U&/')"

echo "Installing $FLAVOR $TYPE APK..."
./gradlew "$INSTALL_TASK"

echo ""
echo "✓ APK installed successfully!"
