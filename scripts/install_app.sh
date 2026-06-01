#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
APP_NAME="SimulatorHelper"
SOURCE_APP_PATH="$ROOT_DIR/.build/AppBundle/$APP_NAME.app"
TARGET_DIR="${HOME}/Applications"
TARGET_APP_PATH="$TARGET_DIR/$APP_NAME.app"

"$ROOT_DIR/scripts/build_app.sh"

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_APP_PATH"
cp -R "$SOURCE_APP_PATH" "$TARGET_APP_PATH"

echo "Installed app bundle:"
echo "  $TARGET_APP_PATH"
echo
echo "You can now launch $APP_NAME by double-clicking the app icon."
