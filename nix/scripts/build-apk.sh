#!/usr/bin/env bash
# Build Meshtastic Android APK

set -exuo pipefail

help() {
  cat << 'EOF'
Build Meshtastic Android APK

Usage: build-apk [FLAVOR] [TYPE]

FLAVOR:
  google    - Google Play flavor (default)
  fdroid    - F-Droid flavor

TYPE:
  debug     - Debug build (default)
  release   - Release build (requires keystore)

Examples:
  build-apk                    # google debug
  build-apk fdroid             # fdroid debug
  build-apk google release     # google release
  build-apk fdroid release     # fdroid release

Output: androidApp/build/outputs/apk/{flavor}/{type}/
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

# Build APK variant
APK_TASK="assemble$(printf '%s\n' "$FLAVOR" | sed 's/^./\U&/')$(printf '%s\n' "$TYPE" | sed 's/^./\U&/')"

echo "Building: $FLAVOR $TYPE APK..."
./gradlew "$APK_TASK"

echo ""
echo "✓ APK built successfully!"
echo "Output: androidApp/build/outputs/apk/$FLAVOR/$TYPE/"
