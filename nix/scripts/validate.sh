#!/usr/bin/env bash
# Run baseline validation for Meshtastic Android

set -euo pipefail

help() {
  cat << 'EOF'
Run baseline validation for Meshtastic Android

Usage: validate [OPTIONS]

OPTIONS:
  --full          Run all checks + tests (default)
  --quick         Run quick checks only (spotless + detekt)
  --no-test       Run checks but skip tests
  -h, --help      Show this help

The full validation runs:
  - spotlessApply
  - spotlessCheck
  - detekt
  - assembleDebug
  - test
  - allTests

This should be run before every push to CI.
EOF
}

MODE="${1:-full}"

case "$MODE" in
  -h|--help)
    help
    exit 0
    ;;
  --quick)
    echo "Running quick validation (spotless + detekt)..."
    ./gradlew spotlessApply spotlessCheck detekt
    ;;
  --no-test)
    echo "Running validation without tests..."
    ./gradlew spotlessApply spotlessCheck detekt assembleDebug
    ;;
  full)
    echo "Running full baseline validation..."
    echo "This may take several minutes..."
    ./gradlew spotlessApply spotlessCheck detekt assembleDebug test allTests
    ;;
  *)
    echo "Error: Unknown mode '$MODE'" >&2
    help
    exit 1
    ;;
esac

echo ""
echo "✓ Validation complete!"
