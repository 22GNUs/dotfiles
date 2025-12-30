return {
  -- flutter
  {
    "akinsho/flutter-tools.nvim",
    lazy = true,
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- optional for vim.ui.select
    },
    widget_guides = {
      enabled = true,
    },
    opts = {
      lsp = {
        color = {
          enabled = true,
          background = true,
          background_color = { r = 19, g = 17, b = 24 },
          foreground = false,
          virtual_text = false, -- show the highlight using virtual text
          virtual_text_str = "■", -- the virtual text character to highlight
        },
      },
    },
    config = function(_, opts)
      require("flutter-tools").setup(opts) -- use defaults
    end,
  },
}
