#!/usr/bin/env bash
# Optional source install. Prefer: omarchy plugin add <git-url> --enable
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="dawei.ocr-translate"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/$PLUGIN_ID"

[[ -f "$ROOT/manifest.json" && -f "$ROOT/OcrTranslate.qml" ]] || {
  echo "missing overlay files in $ROOT" >&2
  exit 1
}
[[ -f "$ROOT/bin/omarchy-ocr-translate" && -f "$ROOT/bin/omarchy-ocr-translate-hotkey" ]] || {
  echo "missing CLI scripts under $ROOT/bin" >&2
  exit 1
}

if [[ "$ROOT" == "$DEST" ]]; then
  echo "already in $DEST"
  exit 0
fi

if [[ -L "$DEST" ]]; then
  rm -f "$DEST"
fi

mkdir -p "$DEST/bin"
cp -f "$ROOT/manifest.json" "$ROOT/OcrTranslate.qml" "$DEST/"
cp -f "$ROOT/bin/omarchy-ocr-translate" "$ROOT/bin/omarchy-ocr-translate-hotkey" "$DEST/bin/"
chmod +x "$DEST/bin/omarchy-ocr-translate" "$DEST/bin/omarchy-ocr-translate-hotkey"

echo "copied plugin -> $DEST"
echo "enable with: omarchy plugin enable $PLUGIN_ID"
echo "preferred install: omarchy plugin add https://github.com/david-crafts/omarchy-ocr-translate.git --enable"
