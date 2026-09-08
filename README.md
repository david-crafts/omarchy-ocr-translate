# omarchy-ocr-translate

Omarchy overlay + CLI: OCR screen text and translate English to Simplified Chinese with DeepSeek.

## Source

This repo: `/home/dawei/Developer/new_runtime/omarchy-ocr-translate`

- `plugin/` — `manifest.json`, `OcrTranslate.qml`
- `bin/omarchy-ocr-translate` — CLI (stdin → stdout)

## Install

```bash
./install.sh
```

Copies `plugin/manifest.json` and `OcrTranslate.qml` into a **real directory**
`~/.config/omarchy/plugins/omarchy.ocr-translate/` (not a symlink; `omarchy plugin validate`
rejects a plugin root that is itself a symlink). Symlinks
`~/.local/bin/omarchy-ocr-translate` to this repo’s `bin/omarchy-ocr-translate`.

Does **not** write or overwrite `~/.config/omarchy/secrets`.

Re-run after editing `plugin/` so the install copy matches the repo.

If a previous install used `dawei.translate` / `omarchy-translate`, remove that
plugin and PATH symlink first (see `docs/rollback.md`), then install this id.

## Key

Copy `secrets/deepseek.env.example` to `~/.config/omarchy/secrets/deepseek.env`
and set `DEEPSEEK_API_KEY`. Without a key, `omarchy-ocr-translate` fails
(missing file or empty `DEEPSEEK_API_KEY`).

## Hotkey

`SUPER+SHIFT+T` toggles the OCR Translate overlay (`omarchy-shell shell toggle omarchy.ocr-translate`).
