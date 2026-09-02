# ocr-translate

Omarchy overlay + CLI: edit clipboard text and translate English to Simplified Chinese with DeepSeek.

## Source

This repo: `/home/dawei/Developer/new_runtime/ocr-translate`

- `plugin/` — `manifest.json`, `Translate.qml`
- `bin/omarchy-translate` — CLI (stdin → stdout)

## Install

```bash
./install.sh
```

Copies `plugin/manifest.json` and `Translate.qml` into a **real directory**
`~/.config/omarchy/plugins/dawei.translate/` (not a symlink; `omarchy plugin validate`
rejects a plugin root that is itself a symlink). Symlinks
`~/.local/bin/omarchy-translate` to this repo’s `bin/omarchy-translate`.

Does **not** write or overwrite `~/.config/omarchy/secrets`.

Re-run after editing `plugin/` so the install copy matches the repo.

## Key

Copy `secrets/deepseek.env.example` to `~/.config/omarchy/secrets/deepseek.env`
and set `DEEPSEEK_API_KEY`. Without a key, `omarchy-translate` fails
(missing file or empty `DEEPSEEK_API_KEY`).

## Hotkey

`SUPER+SHIFT+T` toggles the Translate overlay (`omarchy-shell shell toggle dawei.translate`).
