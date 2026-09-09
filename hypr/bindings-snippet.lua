-- SUPER+SHIFT+T: OCR a screen region, then open the translate overlay.
-- Leave SUPER+T (float) and SUPER+CTRL+PRINT (system OCR) unchanged.

o.bind("SUPER + SHIFT + T", "OCR Translate",
  os.getenv("HOME") .. "/.config/omarchy/plugins/dawei.ocr-translate/bin/omarchy-ocr-translate-hotkey")
