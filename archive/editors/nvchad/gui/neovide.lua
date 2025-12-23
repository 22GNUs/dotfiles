local g = vim.g
local o = vim.opt
if g.neovide ~= nil then
  o.guifont = { "Iosevka Mayukai Original", ":h18" }
  -- g.neovide_fullscreen = true
  g.neovide_scroll_animation_length = 0.6
  g.neovide_no_idle = true
  g.neovide_refresh_rate = 60
  g.neovide_hide_mouse_when_typing = true
  g.neovide_remember_dimensions = true
  g.neovide_remember_window_size = true

  -- transparency
  -- have bugs when --multigrid enable, disable for now, see https://github.com/neovide/neovide/issues/720
  if g.transparency then
    -- g.neovide_transparency = 0.0
    -- g.transparency = 0.97
    -- local colors = require("base46").get_theme_tb "base_30"
    -- vim.cmd("let g:neovide_background_color = '" .. colors.black .. "'.printf('%x', float2nr(255 * g:transparency))")
    -- close for now
    g.transparency = false
    local transparency = require("custom.settings").transparency
    o.winblend = transparency.winblend()
    o.pumblend = transparency.pumblend()
  end

  -- blur
  g.neovide_floating_blur_amount_x = 2.0
  g.neovide_floating_blur_amount_y = 2.0
  -- vfx mode
  -- g.neovide_cursor_vfx_mode = "ripple"
  g.neovide_cursor_vfx_mode = "railgun"
  g.neovide_cursor_vfx_particle_phase = 1.5
  g.neovide_cursor_vfx_particle_curl = 1.0

  -- fix neovide system clipboard
  -- in macos, c means <ctrl>, D means <cmd>
  vim.cmd 'nmap <D-c> "+y'
  vim.cmd 'vmap <D-c> "+y'
  vim.cmd 'nmap <D-v> "+p'
  -- in normal mode <c-r> will open reigster
  vim.cmd "inoremap <D-v> <c-r>+"
  vim.cmd "cnoremap <D-v> <c-r>+"
end
