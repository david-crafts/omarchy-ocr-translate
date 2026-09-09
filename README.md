# omarchy-ocr-translate

Screen-region OCR and English → Simplified Chinese translation for [Omarchy](https://omarchy.org/).

Press **Super+Shift+T**, select a region, and an overlay opens with the recognized text already translated.

## How it works

1. The hotkey hides the overlay if it is already open, so it does not cover the screen.
2. The same pipeline as `omarchy capture text` freezes the display, lets you select a region, and runs Tesseract.
3. On success the text is copied to the clipboard and the overlay is summoned.
4. The overlay pastes the clipboard and translates through DeepSeek.

Canceling the selection, or getting empty OCR, does nothing. Leftover clipboard text is not translated.

The plugin id is `dawei.ocr-translate`. Third-party plugins cannot use the reserved `omarchy.*` namespace.

## Requirements

- [Omarchy](https://omarchy.org/) (Hyprland + omarchy-shell)
- `grim`, `slurp`, `hyprpicker`, `tesseract`, `wl-copy`, `jq`, `curl`
- Tesseract language data for `eng` (the default)
- A [DeepSeek API key](https://platform.deepseek.com)

## Install

```bash
git clone git@github.com:david-crafts/omarchy-ocr-translate.git
cd omarchy-ocr-translate
./install.sh
```

This copies the overlay into `~/.config/omarchy/plugins/dawei.ocr-translate/` and links:

- `~/.local/bin/omarchy-ocr-translate`
- `~/.local/bin/omarchy-ocr-translate-hotkey`

It does not write `~/.config/omarchy/secrets`. Re-run `./install.sh` after editing `plugin/` so the installed copy matches the repo.

Then enable the overlay if it is not already listed as enabled:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/dawei.ocr-translate
omarchy-shell shell rescanPlugins
omarchy plugin enable dawei.ocr-translate
```

## Configuration

### API key

```bash
mkdir -p ~/.config/omarchy/secrets
cp secrets/deepseek.env.example ~/.config/omarchy/secrets/deepseek.env
chmod 600 ~/.config/omarchy/secrets/deepseek.env
```

Edit the file and set `DEEPSEEK_API_KEY`. The translate CLI reads that file only; it is not exported into the desktop session.

### Keybinding

Add this to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + SHIFT + T", "OCR Translate", "omarchy-ocr-translate-hotkey")
```

Reload Hyprland (`hyprctl reload`) and confirm `hyprctl configerrors` is empty.

Leave **Super+T** (window float) and **Super+Ctrl+Print** (system OCR to clipboard) alone.

### OCR language

Default is English:

```bash
# optional; default is eng
export OMARCHY_OCR_LANGS=eng
```

Mixed Chinese/English needs extra Tesseract data, for example `eng+chi_sim`, and is not required for the default English → Chinese flow.

## Uninstall

See [docs/uninstall.md](docs/uninstall.md). Do not run `omarchy refresh shell` or `omarchy refresh hyprland` just to remove this overlay.

## License

[MIT](LICENSE)
