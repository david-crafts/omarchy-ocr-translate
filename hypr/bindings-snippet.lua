-- ISS-006 / S7: bind SUPER+SHIFT+T to the OCR Translate overlay.
-- SUPER SHIFT + T was free (omarchy menu keybindings --print); no hl.unbind.
-- Do not change SUPER+T (floating). Do not edit /usr/share/omarchy.
-- Live copy: append the o.bind line to ~/.config/hypr/bindings.lua after backup.

o.bind("SUPER + SHIFT + T", "OCR Translate", "omarchy-shell shell toggle omarchy.ocr-translate")
