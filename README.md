# omarchy-ocr-translate

Screen-region OCR and English → Simplified Chinese translation for [Omarchy](https://omarchy.org/).

Press **Super+Shift+T**, select a region, and an overlay opens with the recognized text already translated.

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

If you installed from a local clone, the example file is `secrets/deepseek.env.example` in that clone. Edit `deepseek.env` and set `DEEPSEEK_API_KEY` from [DeepSeek](https://platform.deepseek.com). The translate CLI reads that file only.

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
4. The overlay pastes the clipboard and translates through DeepSeek.

Canceling the selection, or getting empty OCR, does nothing. Leftover clipboard text is not translated.

The plugin id is `dawei.ocr-translate`. Third-party plugins cannot use the reserved `omarchy.*` namespace.

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
