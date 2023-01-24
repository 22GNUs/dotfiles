-- User custom settings
local M = {}
-- Control floating window transparency
-- Disabled in transparency mode
M.transparency = {
  winblend = function()
    return vim.g.transparency and 0 or 20
  end,
  pumblend = function()
    return vim.g.transparency and 0 or 20
  end,
}

return M
