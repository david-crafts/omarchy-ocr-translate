-- Factory Hyprland bindings for dawei.ocr-translate.
--
-- Omarchy keeps user keys in ~/.config/hypr/bindings.lua. Load this file from
-- there (see hypr/bindings-snippet.lua). Defaults:
--   Super+Shift+T  OCR a screen region
--   Super+Shift+D  translate selected text (no OCR)
-- Super+Shift+D replaces the preinstalled Docker TUI bind. Leave Super+T
-- (float) and Super+Ctrl+Print (system OCR) alone.
--
-- Change chords after dofile:
--   ocr_translate.bind({ ocr = "SUPER + S", selection = "SUPER + D" })

ocr_translate = ocr_translate or {}

local src = debug.getinfo(1, "S").source
local plugin_dir = src:match("^@(.+)/hypr/[^/]+$")
if not plugin_dir or plugin_dir == "" then
  plugin_dir = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/dawei.ocr-translate"
end
local hotkey = plugin_dir .. "/bin/omarchy-ocr-translate-hotkey"

local bound = { ocr = nil, selection = nil }

local function unbind(keys)
  if keys and keys ~= "" then
    pcall(hl.unbind, keys)
  end
end

-- Same chords as Omarchy Super+C. send_key_state uses explicit mods so the
-- physically held Super is not merged into the copy shortcut (wtype would).
local function send_copy_once(mods, key)
  hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end

local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end
  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end
  return false
end

function ocr_translate.selection()
  -- Snapshot clipboard atomically before synthesizing copy. A truncated
  -- old-clip from a hanging wl-paste used to look "changed" and translate
  -- leftover clipboard (e.g. an email).
  hl.dispatch(hl.dsp.exec_cmd(hotkey .. " --snapshot"))
  hl.timer(function()
    if active_window_is_terminal() then
      send_copy_once("CTRL", "Insert")
    else
      send_copy_once("CTRL", "C")
    end
    hl.timer(function()
      hl.dispatch(hl.dsp.exec_cmd(hotkey .. " --clipboard"))
    end, { timeout = 280, type = "oneshot" })
  end, { timeout = 400, type = "oneshot" })
end

function ocr_translate.bind(opts)
  opts = opts or {}
  local ocr_keys = opts.ocr or "SUPER + SHIFT + T"
  local selection_keys = opts.selection or "SUPER + SHIFT + D"

  unbind(bound.ocr)
  unbind(bound.selection)
  unbind(ocr_keys)
  unbind(selection_keys)

  o.bind(ocr_keys, "OCR Translate", hotkey)
  o.bind(selection_keys, "Translate selection", ocr_translate.selection)

  bound.ocr = ocr_keys
  bound.selection = selection_keys
end
