local g = vim.g
local o = vim.opt
if g.neovide ~= nil then
  o.guifont = { "FantasqueSansM Nerd Font", ":h18" }
  -- g.neovide_fullscreen = true
  g.neovide_scroll_animation_length = 0.6
  g.neovide_hide_mouse_when_typing = true
  -- g.neovide_no_idle = true
  g.neovide_refresh_rate = 120
  g.neovide_remember_dimensions = true
  g.neovide_remember_window_size = true
  g.neovide_padding_top = 48

  if g.transparency then
    -- transparency
    g.transparency = false
    g.neovide_transparency = 0.95
    g.neovide_transparency_point = 0.8
    g.winblend = 35
    -- g.pumblend = 35
  end

  -- blur
  g.neovide_floating_blur_amount_x = 5.0
  g.neovide_floating_blur_amount_y = 5.0

  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5

  -- vfx mode
  -- g.neovide_cursor_vfx_mode = "ripple"
  -- g.neovide_cursor_vfx_mode = "railgun"
  -- g.neovide_cursor_vfx_particle_phase = 1.5
  -- g.neovide_cursor_vfx_particle_curl = 1.0

  -- fix neovide system clipboard
  -- in macos, c means <ctrl>, D means <cmd>
  vim.cmd('nmap <D-c> "+y')
  vim.cmd('vmap <D-c> "+y')
  vim.cmd('nmap <D-v> "+p')
  -- in normal mode <c-r> will open reigster
  vim.cmd("inoremap <D-v> <c-r>+")
  vim.cmd("cnoremap <D-v> <c-r>+")
end
