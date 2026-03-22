#!/bin/bash
set -e

SWIFTC="$(xcrun --sdk macosx26.2 --find swiftc)"
SDK="$(xcrun --sdk macosx26.2 --show-sdk-path)"
TARGET="arm64-apple-macosx26.0"
APP="SnapBar.app"
BINARY="$APP/Contents/MacOS/SnapBar"

# Collect all Swift sources (sorted for deterministic order)
SOURCES=$(find Sources/FastStoneX -name "*.swift" | sort | tr '\n' ' ')

echo "==> Compiling SnapBar..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

$SWIFTC $SOURCES \
    -o "$BINARY" \
    -target "$TARGET" \
    -sdk "$SDK" \
    -parse-as-library \
    -disable-sandbox \
    -O

echo "==> Copying Info.plist..."
cp Info.plist "$APP/Contents/"

echo "==> Copying Resources..."
cp Resources/*.svg "$APP/Contents/Resources/"

echo "==> Code signing (ad-hoc)..."
/usr/bin/codesign --force --sign - --entitlements FastStoneX.entitlements "$APP"

echo ""
echo "==> Done: $APP"
echo "    open $APP"
echo ""
echo "NOTE: On first launch, grant Accessibility access in:"
echo "      System Settings > Privacy & Security > Accessibility"
