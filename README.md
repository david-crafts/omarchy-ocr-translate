# omarchy-ocr-translate

Screen-region OCR and translation for [Omarchy](https://omarchy.org/).

Press **Super+Shift+T**, select a region, and an overlay opens with the recognized text already translated. Default direction is English → Simplified Chinese; change both languages on the overlay.

## Install

```bash
omarchy plugin add https://github.com/david-crafts/omarchy-ocr-translate.git --enable
```

Then add a DeepSeek API key and the hotkey below.

Update later with:

```bash
omarchy plugin update dawei.ocr-translate
```

### From a local clone

If you already have the source:

```bash
git clone https://github.com/david-crafts/omarchy-ocr-translate.git
omarchy plugin add ./omarchy-ocr-translate --enable
```

Or copy the overlay in by hand:

```bash
./install.sh
omarchy-shell shell rescanPlugins
omarchy plugin enable dawei.ocr-translate
```

Hand copies are not git checkouts, so `omarchy plugin update` will not apply. Prefer `omarchy plugin add`.

## Configuration

### API key

```bash
mkdir -p ~/.config/omarchy/secrets
cp ~/.config/omarchy/plugins/dawei.ocr-translate/secrets/deepseek.env.example ~/.config/omarchy/secrets/deepseek.env
chmod 600 ~/.config/omarchy/secrets/deepseek.env
```

If you installed from a local clone, the example file is `secrets/deepseek.env.example` in that clone. Edit `deepseek.env` and set `DEEPSEEK_API_KEY` from [DeepSeek](https://platform.deepseek.com). The DeepSeek provider reads that file only. Do not export the key into the desktop session.

### Languages

The overlay has two dropdowns: source and target. Defaults are English → Simplified Chinese.

The last pair is saved to `~/.config/omarchy/ocr-translate/languages.env`:

```
FROM=en
TO=zh-CN
```

Codes come from `bin/languages.tsv` (`en`, `zh-CN`, `zh-TW`, `ja`, `ko`, `es`, `fr`, `de`). The CLI also accepts `--from` / `--to`; if you omit them it reads that file, then falls back to `en` → `zh-CN`.

### Translation provider

Default is DeepSeek. To switch later (after adding another provider script):

```bash
mkdir -p ~/.config/omarchy/ocr-translate
echo deepseek > ~/.config/omarchy/ocr-translate/provider
```

Or pass `--provider NAME` to `bin/omarchy-ocr-translate`.

### Keybinding

Add this to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + T", "OCR Translate",
  os.getenv("HOME") .. "/.config/omarchy/plugins/dawei.ocr-translate/bin/omarchy-ocr-translate-hotkey")
```

Reload Hyprland (`hyprctl reload`) and confirm `hyprctl configerrors` is empty.

Leave **Super+T** (window float) and **Super+Ctrl+Print** (system OCR to clipboard) alone.

## How it works

1. The hotkey hides the overlay if it is already open, so it does not cover the screen.
2. The same pipeline as `omarchy capture text` freezes the display, lets you select a region, and runs Tesseract.
3. On success the text is copied to the clipboard and the overlay is summoned.
4. The overlay pastes the clipboard and translates through the configured provider (DeepSeek by default).

Canceling the selection, or getting empty OCR, does nothing. Leftover clipboard text is not translated.

Change the language dropdowns on the overlay, then press Enter to retranslate in the new direction.

The plugin id is `dawei.ocr-translate`. Third-party plugins cannot use the reserved `omarchy.*` namespace.

## Adding another translation provider

Only DeepSeek is implemented. `bin/omarchy-ocr-translate` is a dispatcher: it parses `--from` / `--to` / `--provider`, resolves language names from `bin/languages.tsv`, then `exec`s `bin/providers/<name>`.

### Files

| Path | Role |
| --- | --- |
| `bin/omarchy-ocr-translate` | Dispatcher. Do not put vendor API calls here. |
| `bin/providers/<name>` | One executable script per vendor. Name is `[a-zA-Z0-9_-]+`. |
| `bin/languages.tsv` | Language codes and English names. |
| `secrets/<name>.env.example` | Key template committed in git. |
| `~/.config/omarchy/secrets/<name>.env` | Real key file (not in git). |
| `~/.config/omarchy/ocr-translate/provider` | Optional one-line provider name. Default: `deepseek`. |

Do not add stub providers. Do not add a plugin marketplace.

### Contract

The provider process:

- **stdin** — source text (the dispatcher does not consume stdin).
- **stdout** — translation only. No quotes, no commentary.
- **stderr** — errors.
- **exit** — `0` on success; non-zero on failure.
- **args** — `--from LANG --to LANG` (same codes as `bin/languages.tsv`).
- **env** (set by the dispatcher):
  - `OCR_TRANSLATE_FROM` / `OCR_TRANSLATE_TO` — codes
  - `OCR_TRANSLATE_FROM_NAME` / `OCR_TRANSLATE_TO_NAME` — English names for prompts
- **secrets** — source `~/.config/omarchy/secrets/<name>.env` inside the provider only. Never export keys into Hyprland or the systemd user session.

The dispatcher validates the language codes and provider name before exec. Keep DeepSeek working.

To use a new provider: put an executable at `bin/providers/<name>`, then `echo <name> > ~/.config/omarchy/ocr-translate/provider` (or pass `--provider <name>`).

### Prompt for an AI coding agent

Copy everything in the block below into Cursor, pi, Codex, or similar:

```
You are adding a translation provider to the Omarchy overlay plugin omarchy-ocr-translate.

Repo layout: manifest.json and OcrTranslate.qml at the repo root; CLI under bin/. Plugin id is dawei.ocr-translate — do not change it.

Do not bind SUPER+T or SUPER+CTRL+PRINT. Do not edit /usr/share/omarchy/. Do not add a plugin marketplace. Do not add unimplemented stub providers. Keep the built-in DeepSeek provider working.

Add one executable script at bin/providers/<name> (name matches ^[a-zA-Z0-9_-]+$). Follow this contract:

- stdin = source text
- stdout = translation only (no quotes, no explanation)
- stderr = errors; non-zero exit on failure
- args: --from LANG --to LANG
- env from the dispatcher: OCR_TRANSLATE_FROM, OCR_TRANSLATE_TO, OCR_TRANSLATE_FROM_NAME, OCR_TRANSLATE_TO_NAME
- read API keys only from ~/.config/omarchy/secrets/<name>.env (add secrets/<name>.env.example in git). Do not export keys into the desktop session.

bin/omarchy-ocr-translate already execs bin/providers/$name after validating langs. You should not need to change the dispatcher unless the new vendor needs extra flags. Do not put vendor HTTP calls in the dispatcher.

Do not change OcrTranslate.qml unless you are also adding a real provider picker (not required). Do not change the hotkey script; language UI stays on the overlay.

Update README Configuration if the key file path or extra setup differs. Update install.sh only if you add files that the hand-copy install must include (it already copies bin/providers/*).

Self-test:
- bash -n on every new or edited script
- omarchy plugin validate at the repo root
- optional: printf 'hello' | bin/omarchy-ocr-translate --from en --to zh-CN --provider <name>
- do not call a real API unless a key file is already present on the machine
```

## Requirements

- [Omarchy](https://omarchy.org/) (Hyprland + omarchy-shell)
- `grim`, `slurp`, `hyprpicker`, `tesseract`, `wl-copy`, `jq`, `curl`
- Tesseract language data for `eng` (the default)
- A [DeepSeek API key](https://platform.deepseek.com)

Optional: `OMARCHY_OCR_LANGS` (default `eng`). Mixed Chinese/English needs extra Tesseract data such as `eng+chi_sim`.

## Uninstall

```bash
omarchy plugin remove dawei.ocr-translate
```

Then delete the Super+Shift+T line from `~/.config/hypr/bindings.lua`. See [docs/uninstall.md](docs/uninstall.md) for the rest.

## License

[MIT](LICENSE)
