-- VSCodium transparency for Hyprland (Lua config, 0.57+).
-- Load from hyprland.lua with:  require("vscodium")
--
-- Electron can't make only its background transparent, so this is compositor-level opacity:
-- text fades with the background. Your global decoration.blur keeps it readable.
-- The settings.json colour overrides flatten every surface to one colour so the glass looks even.
--
-- Tune live without reloading:
--   hyprctl setprop class:codium opacity 0.90

local M = {}

-- "active inactive". Your global default is 0.95; a step below makes the editor feel lighter
-- while keeping code legible. Go lower on inactive since you're not reading it.
M.rule = hl.window_rule({
    name    = "vscodium-glass",
    match   = { class = "^(codium|VSCodium)$" },
    opacity = "0.88 0.80",
})

-- Popups (file pickers, menus) are separate surfaces; keep them crisp.
M.popups = hl.window_rule({
    name    = "vscodium-dialogs-opaque",
    match   = { class = "^(codium|VSCodium)$", float = true },
    opacity = "1.0 1.0",
})

return M
