# Uninstall

Removes the overlay, hotkey, and CLI symlinks. Do not run this while you still want the feature. Do not run `omarchy refresh shell` or `omarchy refresh hyprland` unless you intend to reset those configs.

## 1. Keybinding

Edit `~/.config/hypr/bindings.lua` and delete:

```lua
o.bind("SUPER + SHIFT + T", "OCR Translate", "omarchy-ocr-translate-hotkey")
```

Leave `SUPER + T` (window float) unchanged. Then:

```bash
hyprctl reload
hyprctl configerrors
```

## 2. Plugin

```bash
omarchy plugin disable dawei.ocr-translate || true
omarchy plugin remove dawei.ocr-translate --yes
omarchy-shell shell rescanPlugins
```

`omarchy plugin remove` moves a hand-installed overlay aside; it does not `rm -rf` the plugin directory. Confirm it is gone:

```bash
omarchy plugin list | grep ocr-translate || echo "plugin gone"
```

## 3. CLI symlinks

These are links into the clone. Removing them does not delete the repository.

```bash
rm -f ~/.local/bin/omarchy-ocr-translate ~/.local/bin/omarchy-ocr-translate-hotkey
```

## 4. API key (optional)

Default is to keep the key for a later reinstall:

```text
~/.config/omarchy/secrets/deepseek.env
```

Delete it only if you want it gone:

```bash
rm -f ~/.config/omarchy/secrets/deepseek.env
```
