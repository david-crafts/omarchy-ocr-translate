-- Add to ~/.config/hypr/bindings.lua (Omarchy's usual place for key overrides).
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/dawei.ocr-translate/hypr/bindings.lua")

-- Factory: Super+Shift+T OCR, Super+Shift+D selected text
-- (Super+Shift+D replaces the preinstalled Docker TUI bind).
ocr_translate.bind()

-- Or pick different chords. bind() unbinds the keys it takes
-- (Super+S is scratchpad).
-- ocr_translate.bind({ ocr = "SUPER + S", selection = "SUPER + D" })
