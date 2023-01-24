local override = require "custom.override"

return {
  -- custom plugins
  ["wakatime/vim-wakatime"] = {},

  ["simrat39/symbols-outline.nvim"] = {
    config = function()
      require("custom.plugins.symbols-outline").setup()
    end,
    setup = function()
      require("core.utils").load_mappings "symbles_outline"
    end,
  },

  ["beauwilliams/focus.nvim"] = {
    config = function()
      require("focus").setup()
    end,
    setup = function()
      require("core.utils").load_mappings "focus"
    end,
  },

  ["jose-elias-alvarez/null-ls.nvim"] = {
    after = "nvim-lspconfig",
    config = function()
      require("custom.plugins.null-ls").setup()
    end,
  },

  -- override plugins

  ["nvim-treesitter/nvim-treesitter"] = {
    override_options = override.treesitter,
  },

  ["williamboman/mason.nvim"] = {
    override_options = override.mason,
  },

  ["NvChad/nvterm"] = {
    override_options = override.nvterm,
  },

  ["lukas-reineke/indent-blankline.nvim"] = {
    override_options = override.blankline,
  },

  ["nvim-telescope/telescope.nvim"] = {
    override_options = override.telescope,
  },

  ["hrsh7th/nvim-cmp"] = {
    override_options = override.cmp,
  },

  ["folke/which-key.nvim"] = {
    disable = false,
    override_options = override.whichkey,
  },

  ["L3MON4D3/LuaSnip"] = {
    config = function()
      -- override default behavior unbind InsertLeave
      -- require("plugins.configs.others").luasnip()
      require "custom.plugins.luasnip"
    end,
  },

  ["neovim/nvim-lspconfig"] = {
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.plugins.lspconfig"
    end,
  },

  ["goolord/alpha-nvim"] = {
    disable = true,
    cmd = "Alpha",
  },
}
