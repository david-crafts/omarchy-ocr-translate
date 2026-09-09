#!/usr/bin/env bash
# Install user plugin + CLI. Does not write ~/.config/omarchy/secrets.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SRC="$ROOT/plugin"
PLUGIN_DEST="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/dawei.ocr-translate"
BIN_SRC="$ROOT/bin/omarchy-ocr-translate"
BIN_DEST="${HOME}/.local/bin/omarchy-ocr-translate"
HOTKEY_SRC="$ROOT/bin/omarchy-ocr-translate-hotkey"
HOTKEY_DEST="${HOME}/.local/bin/omarchy-ocr-translate-hotkey"

[[ -f "$PLUGIN_SRC/manifest.json" && -f "$PLUGIN_SRC/OcrTranslate.qml" ]] || {
  echo "missing plugin files under $PLUGIN_SRC" >&2
  exit 1
}
[[ -x "$BIN_SRC" || -f "$BIN_SRC" ]] || {
  echo "missing $BIN_SRC" >&2
  exit 1
}
[[ -x "$HOTKEY_SRC" || -f "$HOTKEY_SRC" ]] || {
  echo "missing $HOTKEY_SRC" >&2
  exit 1
}

# omarchy plugin validate rejects a plugin directory that is itself a symlink.
if [[ -L "$PLUGIN_DEST" ]]; then
  rm -f "$PLUGIN_DEST"
fi
mkdir -p "$PLUGIN_DEST"
cp -f "$PLUGIN_SRC/manifest.json" "$PLUGIN_SRC/OcrTranslate.qml" "$PLUGIN_DEST/"

mkdir -p "$(dirname "$BIN_DEST")"
ln -sfn "$BIN_SRC" "$BIN_DEST"
ln -sfn "$HOTKEY_SRC" "$HOTKEY_DEST"

echo "installed plugin -> $PLUGIN_DEST"
echo "installed cli    -> $BIN_DEST -> $BIN_SRC"
echo "installed hotkey -> $HOTKEY_DEST -> $HOTKEY_SRC"
echo "secrets unchanged (~/.config/omarchy/secrets is not written)"
