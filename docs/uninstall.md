# Uninstall

```bash
omarchy plugin remove dawei.ocr-translate
```

That disables the overlay and removes `~/.config/omarchy/plugins/dawei.ocr-translate/`. Do not run `omarchy refresh shell` or `omarchy refresh hyprland` just to remove this plugin.

## Keybinding

Edit `~/.config/hypr/bindings.lua` and delete the Super+Shift+T OCR Translate binding. Leave `SUPER + T` (window float) unchanged, then:

```bash
hyprctl reload
hyprctl configerrors
```

## API key (optional)

Default is to keep the key for a later reinstall:

```text
~/.config/omarchy/secrets/deepseek.env
```

Delete it only if you want it gone:

```bash
rm -f ~/.config/omarchy/secrets/deepseek.env
```

Language and provider preferences (optional):

```bash
rm -rf ~/.config/omarchy/ocr-translate
```
