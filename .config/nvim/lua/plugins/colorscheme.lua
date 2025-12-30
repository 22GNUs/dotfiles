local transparency = vim.g.transparency
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = transparency,
      style = "night",
      light_style = "day",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    enabled = false,
    opts = {
      transparent_background = transparency,
      highlight_overrides = {
        mocha = function(cp)
          local border_color = cp.blue
          return {
            -- for borders
            CmpBorder = { fg = border_color },
            CmpDocBorder = { fg = border_color },
            TelescopeBorder = { fg = border_color },
            NoiceCmdlinePopupBorder = { fg = border_color },

            AlphaHeader = { fg = cp.lavender },

            -- whichkey
            WhichKeyFloat = { bg = transparency and cp.none or cp.base },

            -- notice
            NotifyBackground = { bg = cp.base },

            -- outline's focused symbol
            FocusedSymbol = { fg = cp.pink },

            -- Remove cursorLine bg
            CursorLine = { bg = cp.none },
            -- Hide fold bg
            Folded = { bg = cp.none },

            -- For trouble.nvim
            TroubleNormal = { bg = transparency and cp.none or cp.base },
            TroubleText = { fg = cp.pink },
          }
        end,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
