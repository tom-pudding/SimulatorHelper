#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
APP_NAME="SimulatorHelper"
APP_IDENTIFIER="com.tomo.simulatorhelper"
BUILD_OUTPUT_DIR="$ROOT_DIR/.build/AppBundle"
APP_BUNDLE_PATH="$BUILD_OUTPUT_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE_PATH/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
SHORT_VERSION="${SIMULATOR_HELPER_VERSION:-0.1.0}"
BUILD_VERSION="$(git -C "$ROOT_DIR" rev-list --count HEAD 2>/dev/null || echo 1)"
LEGACY_VISIBLE_APP_PATH="$ROOT_DIR/Build/$APP_NAME.app"
LEGACY_HIDDEN_DIR="$ROOT_DIR/.build/LegacyAppBundles"

echo "Building $APP_NAME in release mode..."
swift build --package-path "$ROOT_DIR" -c release

BIN_DIR="$(swift build --package-path "$ROOT_DIR" -c release --show-bin-path)"
EXECUTABLE_PATH="$BIN_DIR/$APP_NAME"

if [[ ! -x "$EXECUTABLE_PATH" ]]; then
  echo "Expected executable not found at: $EXECUTABLE_PATH" >&2
  exit 1
fi

rm -rf "$APP_BUNDLE_PATH"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

if [[ -d "$LEGACY_VISIBLE_APP_PATH" ]]; then
  mkdir -p "$LEGACY_HIDDEN_DIR"
  mv "$LEGACY_VISIBLE_APP_PATH" "$LEGACY_HIDDEN_DIR/$APP_NAME.app"
fi

cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

# App icon
ICON_SRC="$ROOT_DIR/scripts/AppIcon.icns"
if [[ -f "$ICON_SRC" ]]; then
  cp "$ICON_SRC" "$RESOURCES_DIR/AppIcon.icns"
fi

cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$APP_IDENTIFIER</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$SHORT_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$BUILD_VERSION</string>
  <key>LSApplicationCategoryType</key>
  <string>public.app-category.developer-tools</string>
  <key>LSMinimumSystemVersion</key>
  <string>15.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
</dict>
</plist>
EOF

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP_BUNDLE_PATH" >/dev/null 2>&1 || true
fi

echo "Created app bundle:"
echo "  $APP_BUNDLE_PATH"
